table 70007 "Consignment Header"
{
    Caption = 'Consignment Header';
    LookupPageId = "Consignment Document List";
    DataClassification = ToBeClassified;
    DataCaptionFields = "Document No.", "Vendor No.", "Start Date", "End Date", Status;

    fields
    {
        field(1; "Document No."; Code[50])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if "Document No." <> xRec."Document No." then begin
                    //NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", "Document Date", "Document No.", "No. Series");
                    "Document No." := NoSeriesMgt.GetNextNo(GetNoSeriesCode());
                end;
            end;
        }
        field(2; "Vendor No."; Code[50])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No." where("Is Consignment Vendor" = filter(true));
            DataClassification = ToBeClassified;
        }
        field(3; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = ToBeClassified;
        }
        field(4; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = ToBeClassified;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = "Open","Released","Posted";
            OptionCaption = 'Open,Released,Posted';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Sales Invoice No."; Code[50])
        {
            Caption = 'Sales Invoice No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."No." where("Consign. Document No." = field("Document No.")));
        }
        field(7; "Posted Sales Invoice No."; Code[50])
        {
            Caption = 'Posted Sales Invoice No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Invoice Header"."No." where("Consign. Document No." = field("Document No.")));

        }
        field(8; "Purchase Invoice No."; Code[50])
        {
            Caption = 'Purchase Invoice No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."No." where("Consign. Document No." = field("Document No."), "Document Type" = filter(2)));
        }
        field(9; "Posted Purchase Invoice No."; Code[50])
        {
            Caption = 'Posted Purchase Invoice No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Purch. Inv. Header"."No." where("Consign. Document No." = field("Document No.")));
        }
        field(10; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(11; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(12; "Email Sent"; Boolean)
        {
            Caption = 'Email Sent';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(13; "E-Mail Sent Timestamp"; DateTime)
        {
            Caption = 'E-Mail Sent Timestamp';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14; "E-Mail Sent User ID"; Code[50])
        {
            Caption = 'E-Mail Send User ID';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(50; "No. Series"; Code[50])
        {
            Caption = 'No. Series';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(60; "No. of Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Consignment Entries" where("Document No." = field("Document No.")));
        }
        field(61; "Total Excl. Tax"; Decimal)
        {
            Caption = 'Total Consign Sales Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Consignment Billing Entries"."Total Excl Tax" where("Document No." = field("Document No.")));
        }
        field(62; "Billing - Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            FieldClass = FlowField;
            CalcFormula = sum("Consignment Billing Entries".Cost where("Document No." = field("Document No.")));
        }
        field(63; "Billing - Total Profit"; Decimal)
        {
            Caption = 'Total Profit';
            FieldClass = FlowField;
            CalcFormula = sum("Consignment Billing Entries".Profit where("Document No." = field("Document No.")));
        }
        field(64; "Billing - Total Exc. Tax"; Decimal)
        {
            Caption = 'Total PI Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Consignment Billing Entries"."Total Excl Tax" where("Document No." = field("Document No.")));
        }
        field(66; "Total MDR Amount"; Decimal)
        {
            Caption = 'Total MDR Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Consignment Billing Entries"."MDR Amount" where("Document No." = field("Document No.")));
        }
        field(70; "Total Store Posted"; Integer) { }
        field(71; "Total Store Posted Amount"; Decimal) { }
        field(72; "Total Store UnPosted"; Integer) { }
        field(73; "Total Store UnPosted Amount"; Decimal) { }
        field(80; "Discrepancy"; Boolean) { }
        field(81; "Contract ID"; Code[20]) { Caption = 'Contract ID'; }
        field(82; "Billing Period ID"; Code[20]) { Caption = 'Billing Period ID'; }

    }


    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
        key(PK2; Status, "Start Date", "End Date") { }
        key(Key3; "Start Date", "End Date", Status, "Document No.", "Vendor No.") { }

    }
    var
        //NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesMgt: Codeunit "No. Series";


    trigger OnInsert()
    begin
        Rec."Document Date" := today;
        Rec."Created By" := UserId;
        if "Document No." = '' then
            //NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", "Document Date", "Document No.", "No. Series");
            "Document No." := NoSeriesMgt.GetNextNo(GetNoSeriesCode());
    end;

    trigger OnDelete()
    var
        ConsignmentEntries: Record "Consignment Entries";
        ConsignmentBillingEntries: record "Consignment Billing Entries";
    begin
        ConsignmentEntries.Reset();
        ConsignmentEntries.SetRange("Document No.", Rec."Document No.");
        ConsignmentEntries.DeleteAll();

        ConsignmentBillingEntries.Reset();
        ConsignmentBillingEntries.SetRange("Document No.", Rec."Document No.");
        ConsignmentBillingEntries.DeleteAll();
    end;

    procedure GetNoSeriesCode(): code[20]
    var
        RetailSetup: Record "LSC Retail Setup";
    begin
        RetailSetup.Reset();
        if RetailSetup.Get() then
            RetailSetup.TestField("Consignment Doc. Nos.");
        exit(RetailSetup."Consignment Doc. Nos.");
    end;
}
