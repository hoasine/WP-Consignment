table 70016 "WP MPG Setup"
{
    Caption = 'WP MPG Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(2; "Contract ID"; Code[20])
        {
            Caption = 'Contract ID';
            TableRelation = "WP Consignment Contracts"."ID";
        }
        field(3; "Contract Type"; Option)
        {
            Caption = 'Contract Type';
            OptionMembers = "Normal","Event";
            FieldClass = FlowField;
            CalcFormula = lookup("WP Consignment Contracts"."Contract Type" WHERE("ID" = FIELD("Contract ID")));
        }
        field(4; "Description"; Text[50])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup("WP Consignment Contracts"."Description" WHERE("ID" = FIELD("Contract ID")));
        }
        field(5; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
        }
        field(6; "Billing Period ID"; Code[20])
        {
            Caption = 'Billing Period ID';
            TableRelation = "WP B.Inc Billing Periods"."ID" where("Consignment Billing Type" = filter('Buying Income'));
        }
        field(7; "Start Date"; Date)
        {
            Caption = 'Start Date';
            FieldClass = FlowField;
            CalcFormula = lookup("WP B.Inc Billing Periods"."Start Date" WHERE("ID" = FIELD("Billing Period ID")));
        }
        field(8; "End Date"; Date)
        {
            Caption = 'End Date';
            FieldClass = FlowField;
            CalcFormula = lookup("WP B.Inc Billing Periods"."Start Date" WHERE("ID" = FIELD("Billing Period ID")));
        }
        field(9; "Expected Gross Profit"; Decimal)
        {
            Caption = 'Expected Gross Profit';
        }
    }
    keys
    {
        key(PK; "Vendor No.", "Contract ID", "Store No.", "Billing Period ID")
        {
            Clustered = true;
        }
    }
}
