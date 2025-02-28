//001   edo 20230529    Add Table Relation to Consign. Prod Posting Groups field
//20200909 STFU-
tableextension 58030 STFURetailSetupExt extends "LSC Retail Setup"
{
    fields
    {
        field(58000; "Supplier Trading Batch ID"; Code[20])
        {
            Caption = 'Supplier Trading Batch ID';
            TableRelation = "No. Series".Code;
        }
        field(58001; "Def. Purch. Inv. G/L Acc."; code[20])
        {
            Caption = 'Def. Purch. Inv. G/L Acc.';
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true));
            DataClassification = ToBeClassified;
        }
        field(58002; "Def. Sales Inv. G/L Acc."; code[20])
        {
            Caption = 'Def. Sales Inv. G/L Acc.';
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true));
            DataClassification = ToBeClassified;
        }
        field(58003; "Enable Auto E-Mail PI/SI"; Boolean)
        {
            Caption = 'Enable Auto E-Mail PI/SI';
            DataClassification = ToBeClassified;
        }
        field(58004; "Scheduler Cut-off Date"; DateFormula)
        {
            Caption = 'Scheduler Cut-off Date';
            DataClassification = ToBeClassified;
        }
        field(58005; "Consignment Attachment Path"; text[250])
        {
            Caption = 'Consignment Attachment Path';
            DataClassification = ToBeClassified;
        }
        field(58006; "Consign. Prod. Posting Groups"; text[250])
        {
            Caption = 'Consign. Prod. Posting Groups';
            //TableRelation = "Gen. Product Posting Group".Code;
            DataClassification = ToBeClassified;
        }

        field(58007; "Consignment Doc. Nos."; code[20]) { TableRelation = "No. Series".Code; }
        field(58008; "Consign. E-Mail Body Text"; Blob)
        {
            Caption = 'Consign. E-Mail Body Text';
            DataClassification = ToBeClassified;
        }
        field(58100; "TTA Store No."; Code[20]) { TableRelation = "LSC Store"."No."; }
        field(58101; "TTA Next Scheduler Date"; Date) { }
        field(58102; "SB Next Scheduler Date"; Date) { }
        field(58103; "SS Next Scheduler Date"; Date) { }
        field(58104; "Scan Sales Attachment Path"; Text[250]) { }
        field(58015; "Auto Post - SI"; Boolean) { Caption = 'Auto Post - Sales Invoice'; } //IST-00007-+
        field(58016; "Auto Post - PI"; Boolean) { Caption = 'Auto Post - Purchase Invoice'; }//IST-00007-+
        field(58017; "Consignment Calc. Cycle"; Enum "Consignment Calc. Cycle") { }//IST-00007-+
        field(58018; "Consign. Calc. Days/Months"; Integer) { MinValue = 1; }//IST-00007-+
        field(58019; "Consign. Calc. Start Date"; Date) { }//IST-00007-+

        //20240124-
        field(58110; "Def. Shortcut Dim. 1 - Sales"; Code[20]) { }
        field(58111; "Def. Shortcut Dim. 1 - Purch"; Code[20]) { }
        //20240124+
        field(58112; "TPR Batch Nos."; Code[20]) { TableRelation = "No. Series"; }
        field(58113; "Billing Period Nos."; Code[20]) { TableRelation = "No. Series"; }
        field(58114; "Consign. Contract Nos."; Code[20]) { TableRelation = "No. Series"; }
    }

    procedure SetEmailBodyText(NewEmailBodyText: Text)
    var
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        Clear("Consign. E-mail Body Text");
        "Consign. E-mail Body Text".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewEmailBodyText);
        Modify();
    end;

    procedure GetEmailBodyText() EmailBodyText: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Consign. E-Mail Body Text");
        "Consign. E-Mail Body Text".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), FieldName("Consign. E-Mail Body Text")));
    end;
}