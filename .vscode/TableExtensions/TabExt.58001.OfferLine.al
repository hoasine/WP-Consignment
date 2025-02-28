tableextension 58001 OfferLine extends "LSC offer line"
{
    fields
    {
        field(50001; "SS Type"; Option)
        {
            Caption = 'SS Type';
            DataClassification = ToBeClassified;
            OptionMembers = "$","%";
        }
        field(50002; "SS Value"; Decimal)
        {
            Caption = 'SS Value';
            DataClassification = ToBeClassified;
        }
    }
}
