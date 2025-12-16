# BlockBench Dashboard - Quick Start

**Status:** ✅ Built and Running  
**URL:** http://localhost:5173/  
**Style:** Elegant, Anthropic-inspired dark mode

---

## What You Got

A beautiful, minimalistic dashboard to explore your 235 blockchain vulnerability samples:

### 🏠 Landing Page

- Elegant project overview
- Live statistics (total samples, languages, vulnerability types, tiers)
- Research questions showcase
- Clean "Explore Dataset" call-to-action

### 🔍 Explorer View

- Dark-mode table with all samples
- Multi-filter support:
  - Language (Solidity, Rust)
  - Difficulty Tier (1-4)
  - Severity (Critical, High, Medium, Low)
  - Vulnerability Type (50+ types)
- Real-time search bar
- Click any row to view details

### 💻 Code Viewer

- Full syntax-highlighted code
- **Vulnerable lines highlighted in RED**
- Metadata sidebar:
  - Vulnerability type & description
  - Fix recommendations
  - Source info & references
- Back navigation

---

## Running It

```bash
# Already running at http://localhost:5173/

# To restart:
cd dashboard
npm run dev
```

---

## Navigation

| Route         | Description                        |
| ------------- | ---------------------------------- |
| `/`           | Landing page with project overview |
| `/explorer`   | Browse and filter dataset          |
| `/sample/:id` | View individual sample with code   |

---

## Design Features

✨ **Anthropic-Inspired Aesthetic:**

- Minimalistic and clean
- Cream (#F5F3EE) and Dark (#1A1A1A) themes
- Orange (#CC785C) accents
- Professional typography
- Subtle transitions

🎨 **UI Highlights:**

- No clutter, content-focused
- Smooth interactions
- High-quality code presentation
- Programmer-friendly dark mode
- Responsive design

---

## When You Add New Data

After processing more samples (Phase 2, 3, etc.), sync the dashboard:

```bash
cd dashboard
npm run sync-dataset
```

Then refresh the browser - your new samples appear automatically!

---

## Tech Stack

- **React 18** - Modern UI framework
- **TypeScript** - Type safety
- **Vite** - Ultra-fast build tool
- **TailwindCSS** - Utility-first styling
- **Prism.js** - Syntax highlighting
- **React Router** - Smooth navigation

---

## What Makes It Special

1. **Reads directly from your dataset** - No separate data management
2. **Anthropic aesthetic** - Professional, minimalistic design
3. **Dark mode first** - Perfect for code review
4. **Vulnerable lines highlighted** - Visual scanning of issues
5. **Fast & responsive** - Vite makes it snappy
6. **Future-proof** - Easy to extend with new features

---

## Quick Tips

**Search:** Type in the search bar to filter by ID, type, or description  
**Filter:** Use dropdowns to narrow by language, tier, severity, or type  
**Navigate:** Click any sample row to see full code  
**Highlight:** Look for red-highlighted lines in code view  
**Back:** Use "Back to Explorer" button or browser back

---

## Next Features (When Needed)

**Phase 3 - Adversarial Variants:**

- Side-by-side comparison view
- Diff highlighting (vulnerable vs patched vs cosmetic)

**Phase 4+:**

- Charts and visualizations
- Export filtered subsets as JSON
- Annotation system for manual review
- Progress tracking toward 500 samples

---

## Files Created

```
dashboard/
├── src/
│   ├── components/
│   │   ├── LandingPage.tsx       # Homepage
│   │   ├── Explorer.tsx          # Dataset browser
│   │   └── CodeViewer.tsx        # Code detail view
│   ├── data/
│   │   └── loader.ts             # Dataset loading
│   ├── types.ts                  # TypeScript types
│   ├── App.tsx                   # Router
│   └── index.css                 # Styles
├── public/
│   └── dataset/
│       └── difficulty_stratified_master.json
├── README.md                     # Full docs
├── DASHBOARD_SETUP.md           # Setup guide
└── package.json
```

---

## Troubleshooting

**Dashboard not loading?**

- Check dev server is running: `cd dashboard && npm run dev`
- Verify dataset JSON exists: `ls public/dataset/`
- Check browser console for errors

**Data not showing?**

- Run sync script: `npm run sync-dataset`
- Verify master JSON has data: `wc -l public/dataset/*.json`

**Need to rebuild?**

- Clean and reinstall: `rm -rf node_modules package-lock.json && npm install`

---

**Dashboard is ready!** 🎉  
Open http://localhost:5173/ and start exploring your blockchain security benchmark.

---

_Part of BlockBench - AI Domain Expertise Evaluation in Blockchain Security_
