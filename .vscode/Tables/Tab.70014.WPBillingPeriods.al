table 70014 "WP B.Inc Billing Periods"
{
    Caption = 'B.Inc Billing Periods';
    DataClassification = ToBeClassified;
    LookupPageId = "WP Billing Periods";

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';
            trigger OnValidate()
            begin
                if "ID" <> xRec."ID" then begin
                    "ID" := NoSeriesMgt.GetNextNo(GetNoSeriesCode());
                end;
            end;
        }
        field(2; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(3; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(4; "Billing Cut-Off Date"; Date)
        {
            Caption = 'Billing Cut-Off Date';
        }
        field(5; "Confirm Email"; Boolean)
        {
            Caption = 'Confirm Email';
        }
        field(6; "Batch Is Done"; Boolean)
        {
            Caption = 'Batch Is Done';
        }
        field(7; "Batch Timestamp"; DateTime)
        {
            Caption = 'Batch Timestamp';
        }
        field(100; "Consignment Billing Type"; Option)
        {
            Caption = 'Consignment Billing Type';
            OptionMembers = "Consignment Sales","Buying Income";
        }
        field(101; "Period Type"; Option)
        {
            Caption = 'Period Type';
            OptionMembers = "Monthly","Bi-Weekly";
        }
        field(102; "Run By USERID"; code[100])
        {
            Caption = 'Run by USERID';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(ConsignmentPeriod; "Consignment Billing Type", "Period Type", "Billing Cut-Off Date", "Batch Is Done")
        {
            Clustered = false;
        }
    }

    local procedure getNoSeriesCode(): Code[20]
    var
        retailsetup: Record "LSC Retail Setup";
    begin
        if retailsetup.get then begin
            retailsetup.TestField("Billing Period Nos.");
            exit(retailsetup."Billing Period Nos.");
        end;

    end;

    trigger OnInsert()
    begin
        if "ID" = '' then
            "ID" := NoSeriesMgt.GetNextNo(GetNoSeriesCode());
    end;

    var
        NoSeriesMgt: Codeunit "No. Series";
}
