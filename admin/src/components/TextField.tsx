"use client";

import type React from "react";
import { fieldClass, labelClass } from "./form-controls";

interface TextFieldProps {
  label: string;
  value: string;
  onChange: (value: string) => void;
  type?: "text" | "email" | "url" | "date" | "number";
  placeholder?: string;
  min?: string;
  step?: string;
  /** Id of a `<datalist>` to offer as suggestions. */
  list?: string;
}

/** Labelled single-line input — the default form control across admin forms. */
export function TextField({
  label,
  value,
  onChange,
  type = "text",
  placeholder,
  min,
  step,
  list,
  children,
}: TextFieldProps & { children?: React.ReactNode }) {
  return (
    <div>
      <label className={labelClass}>{label}</label>
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        min={min}
        step={step}
        list={list}
        className={fieldClass}
      />
      {children}
    </div>
  );
}

export interface SelectOption {
  value: string;
  label: string;
}

/** Labelled select. Generic over the value union so callers keep literal types. */
export function SelectField<T extends string>({
  label,
  value,
  onChange,
  options,
  disabled,
  placeholder,
}: {
  label: string;
  value: T | "";
  onChange: (value: T) => void;
  options: SelectOption[];
  disabled?: boolean;
  placeholder?: string;
}) {
  return (
    <div>
      <label className={labelClass}>{label}</label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value as T)}
        disabled={disabled}
        className={fieldClass}
      >
        {placeholder !== undefined && <option value="">{placeholder}</option>}
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  );
}

export function TextAreaField({
  label,
  value,
  onChange,
  rows = 3,
  placeholder,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  rows?: number;
  placeholder?: string;
}) {
  return (
    <div>
      <label className={labelClass}>{label}</label>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        rows={rows}
        placeholder={placeholder}
        className={`${fieldClass} resize-none`}
      />
    </div>
  );
}
