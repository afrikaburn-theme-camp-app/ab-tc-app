import { describe, it, expect, beforeEach, vi } from "vitest";

const m = vi.hoisted(() => ({
  edition: { id: "ed-1", year: 2027, endDate: "2027-05-02" } as {
    id: string;
    year: number;
    endDate: string;
  } | null,
  ctx: null as { role: string | null; group: { id: string } } | null,
  carry: vi.fn(),
  revalidate: vi.fn(),
  getForEdit: vi.fn(),
}));

vi.mock("next/cache", () => ({ revalidatePath: m.revalidate }));
vi.mock("../session", () => ({
  requireCampUser: async () => ({ id: "user-1", email: "alice@example.com" }),
}));
vi.mock("../edition", () => ({ getActiveEdition: async () => m.edition }));
vi.mock("../project-registration-store", () => ({
  getProjectRegistrationForEdit: m.getForEdit,
  carryForwardProjectRegistration: m.carry,
}));

const { runProjectCarryForward } = await import("../project-carry-forward");

// WHAT THIS PINS. Carrying forward is an EDIT, so it takes the edit gate: only
// the project's structural lead/admin, and only for a slug of the SAME kind.
// The store never runs for anyone else.
describe("runProjectCarryForward", () => {
  beforeEach(() => {
    m.edition = { id: "ed-1", year: 2027, endDate: "2027-05-02" };
    m.carry.mockReset();
    m.revalidate.mockReset();
    m.getForEdit.mockReset();
    m.getForEdit.mockResolvedValue({ role: "lead", group: { id: "g-1" } });
    m.carry.mockResolvedValue({ ok: true });
  });

  it("refuses when no edition is open", async () => {
    m.edition = null;
    const r = await runProjectCarryForward("rusty", "artwork");
    expect(r.ok).toBe(false);
    expect(m.carry).not.toHaveBeenCalled();
  });

  it("answers 'no longer exists' for a slug of another kind", async () => {
    m.getForEdit.mockResolvedValue(null);
    const r = await runProjectCarryForward("rusty", "mutant_vehicle");
    expect(r).toEqual({ ok: false, error: "That project no longer exists." });
    expect(m.carry).not.toHaveBeenCalled();
  });

  it.each([null, "member"])("refuses a caller whose project role is %s", async (role) => {
    m.getForEdit.mockResolvedValue({ role, group: { id: "g-1" } });
    const r = await runProjectCarryForward("rusty", "artwork");
    expect(r.ok).toBe(false);
    expect(m.carry).not.toHaveBeenCalled();
    expect(m.revalidate).not.toHaveBeenCalled();
  });

  it("carries forward for a lead, naming the caller, and revalidates the artwork pages", async () => {
    const r = await runProjectCarryForward("rusty", "artwork");
    expect(r).toEqual({ ok: true });
    expect(m.carry).toHaveBeenCalledWith({
      groupId: "g-1",
      kind: "artwork",
      editionId: "ed-1",
      editionYear: 2027,
      editionEndDate: "2027-05-02",
      editorUserId: "user-1",
      editorEmail: "alice@example.com",
    });
    expect(m.revalidate).toHaveBeenCalledWith("/artworks/rusty/edit");
  });

  it("revalidates the vehicles path for a mutant vehicle", async () => {
    await runProjectCarryForward("beast", "mutant_vehicle");
    expect(m.revalidate).toHaveBeenCalledWith("/vehicles/beast/edit");
  });

  it("does not revalidate when the store refuses", async () => {
    m.carry.mockResolvedValue({ ok: false, error: "nothing to carry" });
    const r = await runProjectCarryForward("rusty", "artwork");
    expect(r.ok).toBe(false);
    expect(m.revalidate).not.toHaveBeenCalled();
  });
});
