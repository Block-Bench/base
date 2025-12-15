# BlockBench Dashboard

An elegant, minimalistic UI for exploring the BlockBench dataset - inspired by Anthropic's design aesthetic.

## Features

- **Landing Page** - Project overview with statistics and research questions
- **Dataset Explorer** - Filter and browse 235+ vulnerability samples
- **Code Viewer** - Syntax-highlighted code with vulnerable lines marked
- **Dark Mode** - Programmer-friendly interface
- **Real-time Filtering** - By language, tier, severity, and type

## Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

The dashboard will be available at `http://localhost:5173`

## Updating Dataset

When you process new data, sync it to the dashboard:

```bash
# From the base directory
npm run sync-dataset

# Or manually
cp dataset/metadata/difficulty_stratified_master.json dashboard/public/dataset/
```

## Tech Stack

- **React 18** + **TypeScript**
- **Vite** - Lightning fast build tool
- **TailwindCSS** - Utility-first styling
- **React Router** - Client-side routing
- **Prism.js** - Syntax highlighting

## Design Philosophy

Inspired by Anthropic's website:

- Minimalistic and elegant
- High-quality typography
- Subtle interactions
- Focus on content
- Professional dark mode

## Structure

```
dashboard/
├── src/
│   ├── components/
│   │   ├── LandingPage.tsx    # Project overview
│   │   ├── Explorer.tsx       # Dataset browser
│   │   └── CodeViewer.tsx     # Code detail view
│   ├── data/
│   │   └── loader.ts          # Dataset loading logic
│   ├── types.ts               # TypeScript types
│   ├── App.tsx                # Main router
│   └── main.tsx               # Entry point
├── public/
│   └── dataset/               # Dataset JSON files
└── package.json
```

## Navigation

- `/` - Landing page
- `/explorer` - Dataset browser
- `/sample/:id` - Individual sample viewer

---

**Part of BlockBench - AI Domain Expertise Evaluation in Blockchain Security**
