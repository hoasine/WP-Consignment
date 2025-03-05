table 70001 "Consignment Rate"
{
    DataCaptionFields = "consignment Type", "Vendor No.", "Store No.", "Starting Date", "Ending Date";
    LookupPageId = "Consignment Master Type";
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced with Consignment Margin Setup Table 70017';
    fields
    {
        field(1; "Consignment Type"; Code[20])
        {
            TableRelation = "Consignment Type".Code;
            trigger OnValidate()
            begin
                CalcFields(Description);
            end;
        }
        field(2; "Vendor No."; Code[20])
        {
            TableRelation = Vendor."No.";
            trigger OnValidate()
            begin
                CalcFields("Vendor Name");
            end;
        }
        field(3; "Store No."; Code[20])
        {
            TableRelation = "LSC Store"."No.";
            trigger OnValidate()
            begin
                CalcFields("Store Name");
            end;
        }
        field(4; "Starting Date"; date)
        {
            trigger OnValidate()
            begin
                CheckDate;
            end;
        }
        field(5; "Ending Date"; Date)
        {
            trigger OnValidate()
            begin
                CheckDate;
            end;
        }
        field(6; "Consignment %"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Caption = 'Profit Margin %';
        }
        field(10; "Description"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Consignment Type".Description where(Code = field("Consignment Type")));
            Editable = false;
        }
        field(11; "Vendor Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(12; "Store Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store".Name where("No." = field("Store No.")));
            Editable = false;
        }
        field(50; "Last Modified By"; Code[50]) { Editable = false; }
        field(51; "Last Modified Date"; DateTime) { Editable = false; }
    }

    keys
    {
        key(PK; "Consignment Type", "Vendor No.", "Store No.", "Starting Date", "Ending Date")
        {
            Clustered = true;
        }
    }

    local procedure CheckDate()
    var
        LText001: TextConst ENU = '%1 can not be before %2';
    begin
        IF ("Starting Date" <> 0D) AND ("Ending Date" <> 0D) AND ("Starting Date" > "Ending Date") THEN
            ERROR(LText001, FIELDCAPTION("Ending Date"), FIELDCAPTION("Starting Date"));

    end;

    var
        consignUtil: Codeunit "Consignment Util";

    trigger OnInsert()
    begin
        clear(consignUtil);
        consignutil.marginBlockActive(today);
        "Last Modified By" := UserId;
        "Last Modified Date" := CurrentDateTime;
        TESTFIELD("Consignment Type");
        TESTFIELD("Vendor No.");
        TESTFIELD("Starting Date");
        //TESTFIELD("Ending Date");
    end;

    trigger OnModify()
    begin
        clear(consignUtil);
        consignutil.marginBlockActive(today);
        "Last Modified By" := UserId;
        "Last Modified Date" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        clear(consignUtil);
        consignutil.marginBlockActive(today);
    end;

}