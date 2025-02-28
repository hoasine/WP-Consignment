table 70017 "WP Consignment Margin Setup"
{
    Caption = 'WP Consignment Margin Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = item."No.";
        }

        field(3; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
        }

        field(4; "Contract ID"; Code[20])
        {
            Caption = 'Contract ID';
            TableRelation = "WP Consignment Contracts".ID;
        }

        field(5; "Start Date"; Date)
        {
            Caption = 'Start Date';
            FieldClass = FlowField;
            CalcFormula = lookup("WP Consignment Contracts"."Start Date" WHERE("ID" = FIELD("Contract ID")));
        }

        field(6; "End Date"; Date)
        {
            Caption = 'End Date';
            FieldClass = FlowField;
            CalcFormula = lookup("WP Consignment Contracts"."End Date" WHERE("ID" = FIELD("Contract ID")));
        }

        field(7; "Disc. From"; Decimal)
        {
            Caption = 'Disc. From';
            DecimalPlaces = 0 : 2;
        }

        field(8; "Disc. To"; Decimal)
        {
            Caption = 'Disc. To';
            DecimalPlaces = 0 : 2;

            trigger OnValidate()
            var
                DiscFrom: Decimal;
            begin
                DiscFrom := Rec."Disc. From";

                if "Disc. To" <= DiscFrom then
                    Error('Disc. To must be greater than Disc. From.');
            end;
        }

        field(9; "Profit Margin"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            // MaxValue = 100;
            // MinValue = 0;
            Caption = 'Profit Margin';
        }
    }
    keys
    {
        key(PK; "Vendor No.", "Item No.", "Store No.", "Contract ID", "Disc. From", "Disc. To")
        {
            Clustered = true;
        }
    }
}
