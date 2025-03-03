tableextension 58039 WPItemJournalLine extends "Item Journal Line"
{
    fields
    {
        field(99000767; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
    }
}
