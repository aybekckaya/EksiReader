export function normalizeSearchText(text: string): string {
  return text
    .trim()
    .replace(/\s+/gu, " ")
    .toLocaleLowerCase("tr-TR")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/gu, "")
    .replaceAll("ı", "i");
}
