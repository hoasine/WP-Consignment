table 70002 "Consignment Setup"
{
    DataClassification = ToBeClassified;
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced with Consignment Margin Setup Table 70017';

    fields
    {
        field(1; "Vendor No."; Code[20]) { }
        field(2; "Hierarchy Type"; Option)
        {
            OptionMembers = All,Division,"Item Category","Product Group","Special Group","Special Group 2",Item;
            OptionCaption = 'All,Division,Item Category,Product Group,Special Group (Prefix B),Special Group 2 (Prefix C),Item';
        }
        field(3; "Sub Type"; Code[20])
        {
            TableRelation = if ("Hierarchy Type" = const(Division)) "LSC Division".Code else
            if ("Hierarchy Type" = const("Item Category")) "Item Category".Code else
            if ("Hierarchy Type" = const("Product Group")) "LSC Retail Product Group".Code else
            if ("Hierarchy Type" = const("Special Group")) "LSC Item Special Groups".Code else
            if ("Hierarchy Type" = const("Special Group 2")) "LSC Item Special Groups".Code else
            if ("Hierarchy Type" = const(Item)) item."No.";
        }
        field(4; "Starting Date"; Date)
        {
            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        field(5; "Ending Date"; Date)
        {
            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        field(6; "Consignment Type"; Code[20])
        {
            TableRelation = "Consignment Type".Code;
            trigger OnValidate()
            begin
                CalcFields("Consignment Description");
            end;
        }
        field(7; "Promotion No."; Code[20])
        {
            TableRelation = "LSC Offer"."No.";
            trigger OnValidate()
            begin
                CalcFields("Promotion Description");
            end;
        }
        field(8; "Periodic Discount Offer"; Code[20])
        {
            TableRelation = "LSC Periodic Discount"."No." where(Type = filter("Disc. Offer" | "Mix&Match" | "Multibuy" | "Line Discount"));

            trigger OnValidate()
            begin
                CalcFields("Periodic Discount Offer Desc.");
                CalcFields("Periodic Disc. Type");
            end;
        }
        field(9; "Indentation"; Integer) { MinValue = 0; }

        field(10; "Total Discount"; Code[20])
        {
            TableRelation = "LSC Periodic Discount"."No." where(Type = filter("Total Discount"));
            trigger OnValidate()
            begin
                CalcFields("Total Discount Desc");
            end;
        }
        field(20; "Vendor Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(21; "Consignment Description"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Consignment Type".Description where(Code = field("Consignment Type")));
            Editable = false;
        }
        field(22; "Promotion Description"; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Offer".Description where("No." = field("Promotion No.")));
            Editable = false;
        }
        field(23; "Periodic Discount Offer Desc."; Text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Periodic Discount".Description where("No." = field("Periodic Discount Offer")));
            Editable = false;
        }
        field(24; "Periodic Disc. Type"; Option)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Periodic Discount".Type where("No." = field("Periodic Discount Offer")));
            OptionMembers = Multibuy,"Mix&Match","Disc. Offer","Total Discount","Tender Type","Item Point","Line Discount";
            OptionCaption = 'Multibuy,Mix&Match,Disc. Offer,Total Discount,Tender Type,Item Point,Line Discount';
            Editable = false;
        }
        field(25; "Line Disc. Pctg."; Integer) { }
        field(26; "Total Discount Desc"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Periodic Discount".Description where("No." = field("Total Discount")));
            Editable = false;
        }
        field(50; "Last Modified By"; Code[50]) { Editable = false; }
        field(51; "Last Modified Date"; DateTime) { Editable = false; }
    }

    keys
    {
        key(PK; "Vendor No.", "Hierarchy Type", "Sub Type", "Consignment Type", "Starting Date", "Ending Date", "Promotion No.", "Periodic Discount Offer")
        {
            Clustered = true;
        }

    }

    local procedure CheckDates()
    begin
        IF ("Starting Date" <> 0D) AND ("Ending Date" <> 0D) AND ("Starting Date" > "Ending Date") THEN
            ERROR(Text001, FIELDCAPTION("Ending Date"), FIELDCAPTION("Starting Date"));
    end;

    procedure UpdateIndent(pVendNo: Code[20])
    var
        ConsignmentStp: Record "Consignment Setup";
    begin
        ConsignmentStp.Reset();
        ConsignmentStp.SetRange("Vendor No.", pVendNo);
        if ConsignmentStp.FindFirst() then begin
            repeat
                case ConsignmentStp."Hierarchy Type" of
                    ConsignmentStp."Hierarchy Type"::All:
                        ConsignmentStp.Indentation := 0;
                    ConsignmentStp."Hierarchy Type"::Division:
                        ConsignmentStp.Indentation := 1;
                    ConsignmentStp."Hierarchy Type"::"Item Category":
                        ConsignmentStp.Indentation := 2;
                    ConsignmentStp."Hierarchy Type"::"Product Group":
                        ConsignmentStp.Indentation := 3;
                    ConsignmentStp."Hierarchy Type"::"Special Group":
                        ConsignmentStp.Indentation := 4;
                    ConsignmentStp."Hierarchy Type"::"Special Group 2":
                        ConsignmentStp.Indentation := 5;
                    ConsignmentStp."Hierarchy Type"::Item:
                        ConsignmentStp.Indentation := 6;
                end;
                ConsignmentStp.Modify();
            until ConsignmentStp.Next() = 0;
        end;
    end;

    var
        Text001: TextConst ENU = '%1 cannot be after %2';
        consignUtil: Codeunit "Consignment Util";

    trigger OnInsert()
    begin
        clear(consignUtil);
        consignUtil.marginBlockActive(today);
        "Last Modified By" := UserId;
        "Last Modified Date" := CurrentDateTime;
        TESTFIELD("Vendor No.");
        //TESTFIELD("Hierarchy Type");
        TESTFIELD("Starting Date");
        //TESTFIELD("Ending Date");
        TESTFIELD("Consignment Type");
        // if "Hierarchy Type" <> "Hierarchy Type"::All then
        //     TestField("Sub Type");
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