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
        field(56; "Start Date"; Date)
        {
            Caption = 'Start Date';

        }
        field(57; "End Date"; Date)
        {
            Caption = 'Ending Date';

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
        field(28; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Posting Setup"."VAT Bus. Posting Group";
        }

        field(9; "Area"; Decimal)
        {
            Caption = 'Area';
            DecimalPlaces = 0 : 2;
        }
        field(29; "Quantity_Area"; Decimal)
        {
            Caption = 'Quantity_Area';
            DecimalPlaces = 0 : 2;
        }
        field(35; "UOM_Area"; Code[20])
        {
            Caption = 'UOM_Area';
            TableRelation = "Unit of Measure".Code;
        }
        field(19; "VAT_Area"; Code[20])
        {
            Caption = 'VAT_Area';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(10; "Amount"; Decimal)
        {
            Caption = 'UnitPrice_Area';
            DecimalPlaces = 0 : 2;
        }
        field(20; "VAT_Parking"; Code[20])
        {
            Caption = 'VAT_Parking';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(36; "Quantity_Parking"; Decimal)
        {
            Caption = 'Quantity_Parking';
            DecimalPlaces = 0 : 2;
        }
        field(37; "UOM_Parking"; Code[20])
        {
            Caption = 'UOM_Parking';
            TableRelation = "Unit of Measure".Code;
        }
        field(11; "Parking"; Decimal)
        {
            Caption = 'UnitPrice_Parking';
            DecimalPlaces = 0 : 2;
        }
        field(21; "VAT_Promotion"; Code[20])
        {
            Caption = 'VAT_Promotion';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(38; "Quantity_Promotion"; Decimal)
        {
            Caption = 'Quantity_Promotion';
            DecimalPlaces = 0 : 2;
        }
        field(39; "UOM_Promotion"; Code[20])
        {
            Caption = 'UOM_Promotion';
            TableRelation = "Unit of Measure".Code;
        }
        field(12; "Promotion"; Decimal)
        {
            Caption = 'UnitPrice_Promotion';
            DecimalPlaces = 0 : 2;
        }
        field(22; "VAT_ST1"; Code[20])
        {
            Caption = 'VAT_ST1';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(40; "Quantity_ST1"; Decimal)
        {
            Caption = 'Quantity_ST1';
            DecimalPlaces = 0 : 2;
        }
        field(41; "UOM_ST1"; Code[20])
        {
            Caption = 'UOM_ST1';
            TableRelation = "Unit of Measure".Code;
        }
        field(13; "Storage1"; Decimal)
        {
            Caption = 'UnitPrice_Storage1';
            DecimalPlaces = 0 : 2;
        }
        field(23; "VAT_ST2"; Code[20])
        {
            Caption = 'VAT_ST2';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(42; "Quantity_ST2"; Decimal)
        {
            Caption = 'Quantity_ST2';
            DecimalPlaces = 0 : 2;
        }
        field(43; "UOM_ST2"; Code[20])
        {
            Caption = 'UOM_ST2';
            TableRelation = "Unit of Measure".Code;
        }
        field(14; "Storage2"; Decimal)
        {
            Caption = 'UnitPrice_Storage2';
            DecimalPlaces = 0 : 2;
        }
        field(24; "VAT_ST3"; Code[20])
        {
            Caption = 'VAT_ST3';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(44; "Quantity_ST3"; Decimal)
        {
            Caption = 'Quantity_ST3';
            DecimalPlaces = 0 : 2;
        }
        field(45; "UOM_ST3"; Code[20])
        {
            Caption = 'UOM_ST3';
            TableRelation = "Unit of Measure".Code;
        }
        field(15; "Storage3"; Decimal)
        {
            Caption = 'UnitPrice_Storage3';
            DecimalPlaces = 0 : 2;
        }
        field(30; "VAT_ST4"; Code[20])
        {
            Caption = 'VAT_ST4';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(46; "Quantity_ST4"; Decimal)
        {
            Caption = 'Quantity_ST4';
            DecimalPlaces = 0 : 2;
        }
        field(47; "UOM_ST4"; Code[20])
        {
            Caption = 'UOM_ST4';
            TableRelation = "Unit of Measure".Code;
        }
        field(26; "Storage4"; Decimal)
        {
            Caption = 'UnitPrice_Storage4';
            DecimalPlaces = 0 : 2;
        }
        field(31; "VAT_ST5"; Code[20])
        {
            Caption = 'VAT_ST5';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(48; "Quantity_ST5"; Decimal)
        {
            Caption = 'Quantity_ST5';
            DecimalPlaces = 0 : 2;
        }
        field(49; "UOM_ST5"; Code[20])
        {
            Caption = 'UOM_ST5';
            TableRelation = "Unit of Measure".Code;
        }
        field(27; "Storage5"; Decimal)
        {
            Caption = 'UnitPrice_Storage5';
            DecimalPlaces = 0 : 2;
        }
        field(32; "VAT_Locker"; Code[20])
        {
            Caption = 'VAT_Locker';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(50; "Quantity_Locker"; Decimal)
        {
            Caption = 'Quantity_Locker';
            DecimalPlaces = 0 : 2;
        }
        field(51; "UOM_Locker"; Code[20])
        {
            Caption = 'UOM_Locker';
            TableRelation = "Unit of Measure".Code;
        }
        field(16; "Locker"; Decimal)
        {
            Caption = 'UnitPrice_Locker';
            DecimalPlaces = 0 : 2;
        }
        field(33; "VAT_Locker1"; Code[20])
        {
            Caption = 'VAT_Locker1';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(52; "Quantity_Locker1"; Decimal)
        {
            Caption = 'Quantity_Locker1';
            DecimalPlaces = 0 : 2;
        }
        field(53; "UOM_Locker1"; Code[20])
        {
            Caption = 'UOM_Locker1';
            TableRelation = "Unit of Measure".Code;
        }
        field(17; "Locker1"; Decimal)
        {
            Caption = 'UnitPrice_Locker1';
            DecimalPlaces = 0 : 2;
        }
        field(34; "VAT_Fixture"; Code[20])
        {
            Caption = 'VAT_Fixture';
            TableRelation = "VAT Posting Setup"."VAT Prod. Posting Group";
        }
        field(54; "Quantity_Fixture"; Decimal)
        {
            Caption = 'Quantity_Fixture';
            DecimalPlaces = 0 : 2;
        }
        field(55; "UOM_Fixture"; Code[20])
        {
            Caption = 'UOM_Fixture';
            TableRelation = "Unit of Measure".Code;
        }
        field(18; "Fixture"; Decimal)
        {
            Caption = 'UnitPrice_Fixture';
            DecimalPlaces = 0 : 2;
        }
    }
    keys
    {
        key(PK; "Vendor No.", "Store No.", "Contract ID", "Location ID", "Floor", "Brand")
        {
            Clustered = true;
        }
        key(PK1; "Vendor No.", "Store No.", "Contract ID", "Start Date", "End Date")
        {
        }
    }
}
