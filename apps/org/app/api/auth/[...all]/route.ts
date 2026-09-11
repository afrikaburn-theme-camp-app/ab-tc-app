import { toNextJsHandler } from "better-auth/next-js";
import { auth } from "@quagga/auth";

// Self-hosted Better Auth mounted in-process for the organiser console
// (docs/technical-spec/01-auth-and-identity.md). Same shared @quagga/auth config as apps/web and
// apps/suppliers, pointed at the same Neon DB — so a session minted here (or on
// another app) is valid across all three via the cross-subdomain cookie.
//
// Env-less boot (AGENTS.md rule 4): the import never throws; requests only work
// once BETTER_AUTH_SECRET is present.
export const { GET, POST } = toNextJsHandler(auth);
