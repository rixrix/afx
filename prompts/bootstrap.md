# AFX Bootstrapping Prompt

> **Purpose**: Copy and paste this prompt into Claude Code (or any AI assistant) when you want to quickly scaffold a new feature spec from a raw idea.

## The Prompt

Copy the prompt below. You can use the provided "SaaS Landing Page" example to test how AFX works, or replace it with your actual feature idea:

```text
I want to build a single-page landing page for my SaaS product. Make it plain, static HTML/CSS/JS with no frameworks (no React, Next.js, etc) so I can easily preview it in my browser.

Please act as my Product Manager and Technical Architect:
1. Ask me 1-3 clarifying questions about this idea. Wait for my response.
2. Once answered, use the `/afx-init` command to scaffold the folder structure.
3. Write the `spec.md`, `design.md`, and `tasks.md` files based on our discussion. Remember to check `CLAUDE.md` for global UI conventions before writing the design document.

When you're done, ask me if I'm ready to run `/afx-task pick` to start coding!
```
