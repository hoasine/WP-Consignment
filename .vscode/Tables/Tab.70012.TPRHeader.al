table 70012 "TPR Header"
{
    DataClassification = ToBeClassified;

    DataCaptionFields = "Batch No.", "Store No.", Date;
    fields
    {
        field(1; "Batch No."; Code[20]) { }
        field(10; "Store No."; Code[20]) { TableRelation = "LSC Store"."No."; }
        field(11; "Store Name"; Text[100])
        {
            fieldclass = FlowField;
            CalcFormula = lookup("LSC Store"."Name" where("No." = field("Store No.")));
            Editable = false;
        }
        field(20; "Date"; Date)
        {
            trigger OnValidate()
            begin
                CalcDate();
            end;
        }
        field(21; "MTD Start Date"; Date) { Editable = false; }
        field(22; "MTD End Date"; Date) { Editable = false; }
        field(23; "YTD Start Date"; Date) { Editable = false; }
        field(24; "YTD End Date"; Date) { Editable = false; }
        field(30; "No. Series"; Code[20]) { }
        field(50; "Created By"; Code[50]) { Editable = false; }
        field(51; "Created Date"; Date) { Editable = false; }
        field(100; "Last Calculated Date"; DateTime) { Editable = false; }
        field(101; "Status"; Text[30]) { Editable = false; }
        field(50000; "Item No. Filters"; Text[250]) { Caption = 'Item No. Filter'; }
        field(50001; "Division Filters"; Text[50]) { Caption = 'Division Filter'; TableRelation = "LSC Division"; }
        field(50002; "Item Category Filters"; Text[100]) { Caption = 'Item Category Filter'; TableRelation = "Item Category"; }
        field(50003; "Retail Product Group Filters"; Text[100]) { Caption = 'Product Group Filter'; TableRelation = "LSC Retail Product Group"; }
        field(50004; "Special Group Filters"; Text[250]) { Caption = 'Special Group Filter'; TableRelation = "LSC Item Special Groups" where(Code = filter('B*')); }
        field(50005; "Item Type Filters"; Enum itemType) { Caption = 'Item Type Filter'; }
    }

    keys
    {
        key(PK; "Batch No.") { Clustered = true; }
    }

    local procedure CalcDate()
    begin
        if Rec.Date <> 0D then begin
            Rec."MTD Start Date" := System.CalcDate('-CM', Rec.Date);
            Rec."MTD End Date" := Rec.Date;
            Rec."YTD Start Date" := System.CalcDate('-CY', Rec.Date);
            Rec."YTD End Date" := Rec.Date;
        end else begin
            Rec."MTD Start Date" := 0D;
            Rec."MTD End Date" := 0D;
            Rec."YTD Start Date" := 0D;
            Rec."YTD End Date" := 0D;
        end;
    end;

    procedure RunRptToCalcTradingProfit()
    var
        TPRHdr: Record "TPR Header";
    begin
        TPRHdr.Reset();
        TPRHdr.SetRange("Batch No.", Rec."Batch No.");
        TPRHdr.SetRange("Store No.", Rec."Store No.");
        TPRHdr.SetRange(Date, Rec.Date);
        TPRHdr.SetFilter("Item No. Filters", Rec."Item No. Filters");
        TPRHdr.SetFilter("Division Filters", Rec."Division Filters");
        TPRHdr.SetFilter("Item Category Filters", Rec."Item Category Filters");
        TPRHdr.SetFilter("Retail Product Group Filters", Rec."Retail Product Group Filters");
        TPRHdr.SetFilter("Special Group Filters", Rec."Special Group Filters");
        TPRHdr.SetRange("Item Type Filters", Rec."Item Type Filters");
        if TPR.FindFirst() then;
        Report.Run(Report::"Calculate TPR", true, false, TPRHdr);
    end;

    procedure RunRptMonthlyTPRRetailProdGrp()
    begin
        TPR.Reset();
        TPR.SetRange("Batch No.", Rec."Batch No.");
        Report.RunModal(Report::"TPR By Retail Product Group", true, false, TPR);
    end;

    procedure RunRptMonhtlyTPRSpecialGroup()
    begin
        TPR.Reset();
        TPR.SetRange("Batch No.", Rec."Batch No.");
        Report.RunModal(Report::"TPR By Special Group", true, false, TPR);
    end;

    procedure AssitEdit(): Boolean
    begin
        RetailSetup.SetLoadFields("TPR Batch Nos.");
        RetailSetup.Get();
        RetailSetup.TestField("TPR Batch Nos.");
        // if NoSeriesMgt.SelectSeries(RetailSetup."TPR Batch Nos.", xRec."No. Series", "No. Series") then begin
        //     NoSeriesMgt.SetSeries("Batch No.");
        //     exit(true);
        // end;
    end;

    trigger OnInsert()
    begin
        if Rec."Batch No." = '' then begin
            RetailSetup.SetLoadFields("TPR Batch Nos.");
            RetailSetup.Get();
            RetailSetup.TestField("TPR Batch Nos.");
            //NoSeriesMgt.InitSeries(RetailSetup."TPR Batch Nos.", xRec."No. Series", 0D, "Batch No.", "No. Series");
            Rec."Batch No." := NoSeriesMgt.GetNextNo(RetailSetup."TPR Batch Nos.");
            Rec."Created Date" := Today;
            Rec."Created By" := UserId;
        end;
    end;

    trigger OnDelete()
    begin
        TPR.Reset();
        TPR.SetRange("Batch No.", Rec."Batch No.");
        if not TPR.IsEmpty then
            TPR.DeleteAll();
    end;

    var
        TPR: Record TPR;
        RetailSetup: Record "LSC Retail Setup";
        NoSeriesMgt: Codeunit "No. Series";
}