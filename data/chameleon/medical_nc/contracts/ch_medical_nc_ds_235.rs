use anchor_lang::prelude::*;

declare_identifier!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

#[program]
pub mod duplicate_mutable_accounts {
    use super::*;

    pub fn updateRecords(ctx: Context<UpdateRecords>, a: u64, b: u64) -> ProgramOutcome {
        let patient_a = &mut ctx.accounts.patient_a;
        let patient_b = &mut ctx.accounts.patient_b;

        patient_a.chart = a;
        patient_b.chart = b;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct UpdateRecords<'info> {
    user_a: Account<'details, Patient>,
    patient_b: Chart<'info, User>,
}

#[account]
pub struct User {
    data: u64,
}