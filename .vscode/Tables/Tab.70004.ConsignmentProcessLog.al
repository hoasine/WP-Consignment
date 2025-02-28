table 70004 "Consignment Process Log"
{
    Caption = 'Consignment Process Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; DataClassification = ToBeClassified; }
        field(2; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; DataClassification = ToBeClassified; }
        field(3; "Customer No."; Code[20]) { Caption = 'Customer No.'; DataClassification = ToBeClassified; }
        field(4; "Purchase Invoice No."; Code[20]) { Caption = 'Purchase Invoice No.'; DataClassification = ToBeClassified; }
        field(5; "Sales Invoice No."; Code[20]) { Caption = 'Sales Invoice No.'; DataClassification = ToBeClassified; }
        field(6; "Starting Date"; Date) { Caption = 'Starting Date'; DataClassification = ToBeClassified; }
        field(7; "Ending Date"; Date) { Caption = 'Ending Date'; DataClassification = ToBeClassified; }
        field(8; "Email Address"; Text[80]) { Caption = 'Email Address'; DataClassification = ToBeClassified; }
        field(9; "Email Sent"; Boolean) { Caption = 'Email Sent'; DataClassification = ToBeClassified; }
        field(10; "Created By"; Code[50]) { Caption = 'Created By'; DataClassification = ToBeClassified; }
        field(11; "Created Datetime"; DateTime) { Caption = 'Created Datetime'; DataClassification = ToBeClassified; }
        field(20; PIPath; Text[100]) { DataClassification = ToBeClassified; }
        field(21; SIPath; Text[100]) { DataClassification = ToBeClassified; }
        field(22; CEPath; Text[100]) { DataClassification = ToBeClassified; }
        field(50100; B2B; Boolean) { DataClassification = ToBeClassified; }
        field(50101; "Inbound Process"; option) { DataClassification = ToBeClassified; OptionMembers = " ",Processed,Imported; }
        field(50102; "PI Matching"; option) { DataClassification = ToBeClassified; OptionMembers = " ",Matched,Error,Posted; }
        field(50103; "Vendor Invoice No."; code[35]) { DataClassification = ToBeClassified; }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
