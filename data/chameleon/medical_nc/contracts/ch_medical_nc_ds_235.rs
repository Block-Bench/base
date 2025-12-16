use anchor_lang::prelude::*;

declare_identifier!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

#[program]
pub mod duplicate_mutable_accounts {
    use super::*;

    pub fn updateChart(ctx: Context<UpdateChart>, a: u64, b: u64) -> ProgramOutcome {
        let enrollee_a = &mut ctx.accounts.enrollee_a;
        let enrollee_b = &mut ctx.accounts.enrollee_b;

        enrollee_a.chart = a;
        enrollee_b.chart = b;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct UpdateChart<'info> {
    user_a: Account<'details, Patient>,
    enrollee_b: Chart<'info, User>,
}

#[account]
pub struct User {
    data: u64,
}