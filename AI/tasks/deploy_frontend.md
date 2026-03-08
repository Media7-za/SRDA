# 1. Task Metadata

## Task Name
Deploy Frontend Application

## File Path
`/ai/tasks/deploy_frontend.md`

## Assigned Agent
- DevOps Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Deploy the Next.js Customer Application (and/or Admin Dashboard) to a CDN-backed edge network (like Vercel or Netlify) for maximum global performance and lowest latency.

---

# 3. Business Context

Customers abandon slow sites. Deploying Next.js to Vercel ensures assets, images, and static HTML are cached globally at the edge, making the menu load instantly.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/devops_agent.md`

---

# 5. Dependencies

- `setup_environment_variables.md`
- Next.js application requires `NEXT_PUBLIC_` variables to be mapped correctly.

---

# 6. Scope

## In Scope
- Connect the Git repository to the Vercel (or preferred) project.
- Configure build settings (Root directory, exact package manager).
- Set custom domain names (e.g., `phuketthai.co.za`).
- Request and enforce SSL/TLS certificates (usually automatic on these networks).

## Out of Scope
- Marketing campaigns or SEO.

---

# 7. Inputs
- DNS Registrar access (e.g., Cloudflare/GoDaddy/Route53).

---

# 8. Required Outputs
- Live application available at the designated production domain.

---

# 9. Acceptance Criteria
- App builds successfully.
- Domain resolves correctly (A-Records/CNAME updated).
- Application renders the Splash Screen and successfully communicates with the live backend (CORS verified).

---

# 10. Implementation Rules
- Verify your Next.js `next.config.js` image domains allow images from your production asset bucket/CDN (e.g., if you map images to S3/Supabase Storage, Next.js blocks them unless whitelisted).

---

# 11. API / Data Contracts
N/A

---

# 12. Edge Cases
- Image optimization limits on Vercel's free tier (if applicable).
- DNS propagation taking up to 48 hours.

---

# 13. Testing Requirements
- Load the live domain on a mobile device on a cellular network to verify performance.

---

# 14. Observability / Logging
- Enable Vercel Analytics/Speed Insights if allowed by budget.

---

# 15. Security / Permissions
- SSL must be active (padlock icon).

---

# 16. Performance Requirements
- Core Web Vitals (LCP, FID, CLS) should be strictly 'Good' as reported by Lighthouse.

---

# 17. Deliverable Format
Deployed application securely mapped to a custom domain.

---

# 18. Completion Checklist
- [ ] Build succeeded
- [ ] Domain mapped
- [ ] SSL active
- [ ] CORS allows traffic to backend
- [ ] Image domains whitelisted

---

# 19. Agent Instruction
You are the DevOps Agent. Vercel deployment is usually one-click, but DNS configuration and CORS debugging are where things go wrong. Triple check that the Backend allows traffic specifically from `https://www.yourcustomdomain.com`.

---
End of File
