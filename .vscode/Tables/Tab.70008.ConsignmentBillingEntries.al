table 70008 "Consignment Billing Entries"
{
    Caption = 'Consignment Billing Entries';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Sales Entries Line No."; Integer)
        {
            Caption = 'Sales Entries Line No.';
            DataClassification = ToBeClassified;
        }
        field(4; "Billing Type"; Option)
        {
            Caption = 'Billing Type';
            DataClassification = ToBeClassified;
            OptionMembers = "Sales","Purchase";
            OptionCaption = 'Sales,Purchase';
        }
        field(5; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            DataClassification = ToBeClassified;
        }
        field(6; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = ToBeClassified;
        }
        field(7; "Product Group"; Code[20])
        {
            Caption = 'Product Group';
            DataClassification = ToBeClassified;
        }
        field(8; "Special Group"; Code[20])
        {
            Caption = 'Special Group';
            DataClassification = ToBeClassified;
        }
        field(9; "Consignment %"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Caption = 'Profit Margin %';
            DataClassification = ToBeClassified;
        }
        field(10; "VAT Code"; Code[20])
        {
            Caption = 'VAT Code';
            DataClassification = ToBeClassified;
        }
        field(11; "Total Excl Tax"; Decimal)
        {
            Caption = 'Total Excl Tax';
            DataClassification = ToBeClassified;
        }
        field(12; "Total Incl Tax"; Decimal)
        {
            Caption = 'Total Incl Tax';
            DataClassification = ToBeClassified;
        }
        field(13; "Total Tax"; Decimal)
        {
            Caption = 'Total Tax';
            DataClassification = ToBeClassified;
        }
        field(14; Cost; Decimal)
        {
            Caption = 'Cost';
            DataClassification = ToBeClassified;
        }
        field(15; Profit; Decimal)
        {
            Caption = 'Profit';
            DataClassification = ToBeClassified;
        }
        field(16; "Product Group Description"; Text[100])
        {
            Caption = 'Product Group Description';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Retail Product Group".Description where(Code = field("Product Group")));
            Editable = false;
        }
        field(17; "Special Group Description"; text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Item Special Groups".Description where("Code" = field("Special Group")));
            Editable = false;
        }
        field(18; "Special Group 2"; Code[20])
        {
            Caption = 'Special Group 2 (Prefix C)';
            DataClassification = ToBeClassified;
        }
        field(19; "Special Group 2 Description"; text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Item Special Groups".Description where("Code" = field("Special Group 2")));
            Editable = false;
        }
        field(20; "Sales Date"; Date)
        {
            Caption = 'Sales Date';
            DataClassification = ToBeClassified;
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
        field(22; "Cost Incl Tax"; Decimal)
        {
            Caption = 'Cost Incl Tax'; //UAT-025 Add Cost WITH TAX
        }
        field(50100; "MDR Rate"; Decimal) { }
        field(50101; "MDR Weight"; Decimal) { }
        field(50102; "MDR Amount"; Decimal) { }
    }
    keys
    {
        key(PK; "Document No.", "line no.")
        {
            Clustered = true;
        }
    }
}
