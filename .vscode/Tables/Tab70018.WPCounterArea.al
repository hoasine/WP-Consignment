table 70018 "WP Counter Area"
{
    Caption = 'WP Counter Area';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
        }
        field(2; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
        }

        field(3; "Store Description"; Text[100])
        {
            Caption = 'Store Description';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."NAme" WHERE("No." = FIELD("Store No.")));
        }

        field(4; "Contract ID"; Code[20])
        {
            Caption = 'Contract ID';
            TableRelation = "WP Consignment Contracts"."ID";
        }

        field(5; "Contract Description"; Text[50])
        {
            Caption = 'Contract Description';
            FieldClass = FlowField;
            CalcFormula = lookup("WP Consignment Contracts"."Description" WHERE("ID" = FIELD("Contract ID")));
        }

        field(6; "Location ID"; Code[20])
        {
            Caption = 'Location ID';
        }

        field(7; Floor; Code[20])
        {
            Caption = 'Floor';
        }

        field(8; Brand; Code[20])
        {
            Caption = 'Brand';
            TableRelation = "LSC Item Special Groups"."Code";
        }

        field(9; "Area"; Decimal)
        {
            Caption = 'Area';
        }
    }
    keys
    {
        key(PK; "Vendor No.", "Store No.", "Contract ID", "Location ID", "Floor", "Brand")
        {
            Clustered = true;
        }
    }
}
