tableextension 58035 PurchaseInvHdr extends "Purch. Inv. Header"
{
    fields
    {
        field(58000; "Consign. Document No."; Code[20])
        {
            Caption = 'Consign. Document No.';
            TableRelation = "Consignment Header"."Document No.";
            DataClassification = ToBeClassified;
        }
    }
}