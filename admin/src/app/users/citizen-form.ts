export interface CitizenFormValues {
  name: string;
  profession: string;
  phone: string;
  village: string;
  email: string;
  address: string;
  nidNumber: string;
  bloodGroup: string;
  dateOfBirth: string;
  photoUrl: string;
}

export const emptyCitizenForm: CitizenFormValues = {
  name: "",
  profession: "",
  phone: "",
  village: "",
  email: "",
  address: "",
  nidNumber: "",
  bloodGroup: "",
  dateOfBirth: "",
  photoUrl: "",
};

/**
 * Mirrors the required fields of `createUserSchema` so the admin sees the
 * problem before a round trip. The server remains the authority.
 */
export function validateCitizenForm(form: CitizenFormValues): string | null {
  if (!form.name.trim()) return "Citizen name is required.";
  if (!form.phone.trim()) return "Phone number is required.";
  if (!form.village.trim()) return "Village name is required.";
  return null;
}
