## Dataset renumbering issues (dataset/ only)

### minimalsanitized (dataset/temporal_contamination/minimalsanitized)

- **Duplicate IDs exist in both active and removed folders**:
  - `ms_tc_004` exists in both:
    - `dataset/temporal_contamination/minimalsanitized/contracts|metadata|code_acts_annotation`
    - `dataset/temporal_contamination/minimalsanitized/removed/contracts|metadata|code_acts_annotation`
  - `ms_tc_014` exists in both active and removed locations as well.

- **Numbering coverage is missing 47–50 despite index claiming 50 files**:
  - Missing sample numbers: `ms_tc_047`, `ms_tc_048`, `ms_tc_049`, `ms_tc_050` (no contract triplets present in dataset for these IDs).

- **`index.json` count mismatch**:
  - `dataset/temporal_contamination/minimalsanitized/index.json` has `"total_files": 50`
  - But the dataset contains only **46** unique `ms_tc_XXX` contract IDs across active+removed.

- **Stray files in `removed/` root directory (not under subfolders)**:
  - `dataset/temporal_contamination/minimalsanitized/removed/ms_tc_006.{sol,json,yaml}`
  - `dataset/temporal_contamination/minimalsanitized/removed/ms_tc_046.{sol,json,yaml}`


