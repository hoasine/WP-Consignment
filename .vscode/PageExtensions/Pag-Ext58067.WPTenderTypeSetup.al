pageextension 58067 WPTenderTypeSetup extends "LSC Tender Type Setup List"
{
    layout
    {
        addafter("Default Function")
        {
            field("Integration MDR Rate"; Rec."Integration MDR Rate")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 3;
            }
        }
    }
}
