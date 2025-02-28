tableextension 58033 Vendor extends Vendor
{
    fields
    {
        field(58000; "Linked Customer No."; Code[20])
        {
            Caption = 'Linked Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = customer."No.";
        }
        field(58001; "Is Consignment Vendor"; Boolean)
        {
            Caption = 'Is Consignment Vendor';
            DataClassification = ToBeClassified;
        }
        field(58002; "Consign. Start Date"; Date)
        {
            Caption = 'Consign. Start Date';
            DataClassification = ToBeClassified;
        }
        field(58003; "Consign. End Date"; Date)
        {
            Caption = 'Consign. End Date';
            DataClassification = ToBeClassified;
        }
        field(58004; "Consign. Billing Frequency"; Option)
        {
            Caption = 'Consign. Billing Frequency';
            DataClassification = ToBeClassified;
            OptionMembers = "Monthly","Bi-Weekly";
        }
        field(58005; "Daily Sales E-Mail"; Text[100])
        {
            Caption = 'Daily Sales E-Mail';
            DataClassification = ToBeClassified;
        }
    }
}