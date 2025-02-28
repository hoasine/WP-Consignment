tableextension 58002 transSalesEntryExt extends "LSC Trans. Sales Entry"
{
    keys
    {
        key(Consign; "Store No.", "POS Terminal No.", "Transaction No.", Date, "Gen. Prod. Posting Group")
        {
            SumIndexFields = "Net Amount";
        }
    }
}