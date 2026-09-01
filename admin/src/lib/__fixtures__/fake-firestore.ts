/**
 * Minimal in-memory Firestore stand-in for route tests. Supports the subset the
 * API routes use: document get/set/update/delete, single-field equality
 * queries, transactions, and the `FieldValue` sentinels.
 *
 * Writes inside a transaction are buffered and applied on commit, so a handler
 * that throws part-way leaves the store untouched — the property the fund
 * reversal logic depends on.
 */

export const SERVER_TIMESTAMP = Symbol("serverTimestamp");

interface IncrementSentinel {
  __increment: number;
}

export function isIncrement(value: unknown): value is IncrementSentinel {
  return typeof value === "object" && value !== null && "__increment" in value;
}

export const FieldValue = {
  serverTimestamp: () => SERVER_TIMESTAMP,
  increment: (amount: number): IncrementSentinel => ({ __increment: amount }),
};

type DocData = Record<string, unknown>;

function applyValues(target: DocData, patch: DocData): DocData {
  const next = { ...target };
  for (const [key, value] of Object.entries(patch)) {
    next[key] = isIncrement(value)
      ? Number(next[key] ?? 0) + value.__increment
      : value;
  }
  return next;
}

interface PendingWrite {
  path: string;
  apply: (current: DocData | undefined) => DocData | undefined;
}

export class FakeFirestore {
  /** Document path (`collection/id`) to its data. */
  readonly docs = new Map<string, DocData>();
  private autoId = 0;

  seed(path: string, data: DocData) {
    this.docs.set(path, data);
  }

  get(path: string): DocData | undefined {
    return this.docs.get(path);
  }

  /** All documents in a collection, as `[id, data]` pairs. */
  collectionDocs(name: string): Array<[string, DocData]> {
    return Array.from(this.docs.entries())
      .filter(([path]) => path.startsWith(`${name}/`))
      .map(([path, data]) => [path.slice(name.length + 1), data]);
  }

  private nextId(): string {
    this.autoId += 1;
    return `auto-${this.autoId}`;
  }

  collection = (name: string) => ({
    doc: (id?: string) => this.docRef(name, id ?? this.nextId()),
    where: (field: string, _op: "==", value: unknown) => ({
      __collection: name,
      __field: field,
      __value: value,
    }),
    orderBy: () => ({
      get: async () => ({
        docs: this.collectionDocs(name).map(([id, data]) => ({
          id,
          data: () => data,
        })),
      }),
    }),
    add: async (data: DocData) => {
      const ref = this.docRef(name, this.nextId());
      this.docs.set(ref.path, applyValues({}, data));
      return ref;
    },
  });

  docRef = (collection: string, id: string) => {
    const path = `${collection}/${id}`;
    return {
      id,
      path,
      get: async () => this.snapshot(path),
      set: async (data: DocData, options?: { merge?: boolean }) => {
        this.docs.set(
          path,
          applyValues(options?.merge ? (this.docs.get(path) ?? {}) : {}, data)
        );
      },
      update: async (data: DocData) => {
        this.docs.set(path, applyValues(this.docs.get(path) ?? {}, data));
      },
      delete: async () => {
        this.docs.delete(path);
      },
    };
  };

  snapshot(path: string) {
    const data = this.docs.get(path);
    return {
      exists: data !== undefined,
      id: path.split("/").pop() as string,
      data: () => data,
    };
  }

  doc(path: string) {
    const [collection, id] = path.split("/");
    return this.docRef(collection, id);
  }

  async runTransaction<T>(
    fn: (tx: FakeTransaction) => Promise<T>
  ): Promise<T> {
    const writes: PendingWrite[] = [];
    const tx = new FakeTransaction(this, writes);
    const result = await fn(tx);

    for (const write of writes) {
      const next = write.apply(this.docs.get(write.path));
      if (next === undefined) this.docs.delete(write.path);
      else this.docs.set(write.path, next);
    }

    return result;
  }
}

interface RefLike {
  path: string;
  id: string;
}

interface QueryLike {
  __collection: string;
  __field: string;
  __value: unknown;
}

function isQuery(value: unknown): value is QueryLike {
  return typeof value === "object" && value !== null && "__collection" in value;
}

export class FakeTransaction {
  constructor(
    private readonly store: FakeFirestore,
    private readonly writes: PendingWrite[]
  ) {}

  async get(target: RefLike | QueryLike) {
    if (isQuery(target)) {
      const docs = this.store
        .collectionDocs(target.__collection)
        .filter(([, data]) => data[target.__field] === target.__value)
        .map(([id, data]) => ({
          id,
          data: () => data,
          ref: this.store.docRef(target.__collection, id),
        }));
      return { docs, empty: docs.length === 0 };
    }
    return this.store.snapshot(target.path);
  }

  set(ref: RefLike, data: DocData, options?: { merge?: boolean }) {
    this.writes.push({
      path: ref.path,
      apply: (current) => applyValues(options?.merge ? (current ?? {}) : {}, data),
    });
  }

  update(ref: RefLike, data: DocData) {
    this.writes.push({
      path: ref.path,
      apply: (current) => applyValues(current ?? {}, data),
    });
  }

  delete(ref: RefLike) {
    this.writes.push({ path: ref.path, apply: () => undefined });
  }
}

