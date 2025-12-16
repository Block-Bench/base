use anchor_lang::prelude::*;

declare_identifier!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

#[program]
pub mod duplicate_mutable_accounts {
    use super::*;

    pub fn refreshStats(ctx: Context<RefreshStats>, a: u64, b: u64) -> ProgramProduct {
        let character_a = &mut ctx.accounts.character_a;
        let player_b = &mut ctx.accounts.player_b;

        character_a.info = a;
        player_b.info = b;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct RefreshStats<'info> {
    user_a: Account<'details, Hero>,
    player_b: Profile<'info, User>,
}

#[account]
pub struct User {
    data: u64,
}