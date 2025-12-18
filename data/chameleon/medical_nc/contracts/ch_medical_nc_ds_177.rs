use anchor_lang::prelude::*;

declare_identifier!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

#[program]
pub mod core_logic {
    use super::*;

    pub fn inspectstatus_sysvar_facility(ctx: Context<InspectstatusSysvarWard>) -> Finding<()> {
        msg!("Rent Key -> {}", ctx.accounts.rent.accessor().destination_text());
        Ok(())
    }
}

#[derive(Accounts)]
pub struct InspectstatusSysvarWard<'info> {
    rent: AccountInfo<'data>,
}