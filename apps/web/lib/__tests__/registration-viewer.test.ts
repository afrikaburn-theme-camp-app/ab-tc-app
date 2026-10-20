import { describe, it, expect, beforeEach, vi } from "vitest";

const m = vi.hoisted(() => ({
  configured: true,
  authUser: { id: "auth-1" } as { id: string } | null,
  campUser: { id: "user-1" } as { id: string } | null,
  edition: { id: "ed-1", year: 2027 } as { id: string; year: number } | null,
  context: null as { role: string | null } | null,
  enforceGate: vi.fn(),
  getContext: vi.fn(),
}));

class Redirect extends Error {
  constructor(public to: string) {
    super(`redirect:${to}`);
  }
}
class NotFound extends Error {}

vi.mock("next/navigation", () => ({
  redirect: (to: string) => {
    throw new Redirect(to);
  },
  notFound: () => {
    throw new NotFound();
  },
}));
vi.mock("../config", () => ({ isDatabaseConfigured: () => m.configured }));
vi.mock("../auth", () => ({ getAuthenticatedUser: async () => m.authUser }));
vi.mock("../session", () => ({
  getCurrentCampUser: async () => m.campUser,
  enforceGate: m.enforceGate,
}));
vi.mock("../edition", () => ({ getActiveEdition: async () => m.edition }));
vi.mock("../registration-store", () => ({
  getRegistrationCampContext: m.getContext,
}));

const { requireRegistrationViewer } = await import("../registration-viewer");

// WHAT THIS PINS. The history and "what changed" pages are only as private as
// this door. The role check is @quagga/core's `canViewCampRegistration`; these
// cases prove the door asks it, in order, and that a refusal lands somewhere
// harmless (never a render of the camp's registration).
describe("requireRegistrationViewer", () => {
  beforeEach(() => {
    m.configured = true;
    m.authUser = { id: "auth-1" };
    m.campUser = { id: "user-1" };
    m.edition = { id: "ed-1", year: 2027 };
    m.enforceGate.mockReset();
    m.getContext.mockReset();
    m.getContext.mockResolvedValue({ role: "lead" });
  });

  it("reports not-configured without touching auth when there is no database", async () => {
    m.configured = false;
    expect(await requireRegistrationViewer("mad-hatters")).toEqual({ configured: false });
    expect(m.getContext).not.toHaveBeenCalled();
  });

  it("sends a signed-out visitor to sign-in", async () => {
    m.authUser = null;
    await expect(requireRegistrationViewer("mad-hatters")).rejects.toMatchObject({
      to: "/auth/sign-in",
    });
    expect(m.getContext).not.toHaveBeenCalled();
  });

  it("sends an auth user with no camp user to sign-in", async () => {
    m.campUser = null;
    await expect(requireRegistrationViewer("mad-hatters")).rejects.toMatchObject({
      to: "/auth/sign-in",
    });
  });

  it("runs the blocking-questionnaire gate before loading anything", async () => {
    m.enforceGate.mockRejectedValue(new Redirect("/questionnaires/x"));
    await expect(requireRegistrationViewer("mad-hatters")).rejects.toMatchObject({
      to: "/questionnaires/x",
    });
    expect(m.getContext).not.toHaveBeenCalled();
  });

  it("is not-configured when no edition is open", async () => {
    m.edition = null;
    expect(await requireRegistrationViewer("mad-hatters")).toEqual({ configured: false });
  });

  it("answers 404 for a camp that does not exist", async () => {
    m.getContext.mockResolvedValue(null);
    await expect(requireRegistrationViewer("nope")).rejects.toBeInstanceOf(NotFound);
  });

  it.each([null, "member"])("sends a viewer with role %s back to the camp page", async (role) => {
    m.getContext.mockResolvedValue({ role });
    await expect(requireRegistrationViewer("mad-hatters")).rejects.toMatchObject({
      to: "/camps/mad-hatters",
    });
  });

  it.each(["lead", "admin"])("lets a %s through with the camp context", async (role) => {
    const context = { role };
    m.getContext.mockResolvedValue(context);
    expect(await requireRegistrationViewer("mad-hatters")).toEqual({
      configured: true,
      campUserId: "user-1",
      context,
    });
  });
});
