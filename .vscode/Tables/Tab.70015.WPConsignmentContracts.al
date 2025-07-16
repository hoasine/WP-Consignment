table 70015 "WP Consignment Contracts"
{
    Caption = 'WP Consignment Contracts';
    DataClassification = ToBeClassified;
    LookupPageId = "WP Consignment Contracts";

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';
           /*  trigger OnValidate()
            begin
                if "ID" <> xRec."ID" then begin
                    "ID" := NoSeriesMgt.GetNextNo(GetNoSeriesCode());
                end;
            end; */
        }
        field(2; "Contract Type"; Option)
        {
            Caption = 'Contract Type';
            OptionMembers = "Normal","Event";
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
    local procedure getNoSeriesCode(): Code[20]
    var
        retailsetup: Record "LSC Retail Setup";
    begin
        if retailsetup.get then begin
            retailsetup.TestField("Consign. Contract Nos.");
            exit(retailsetup."Consign. Contract Nos.");
        end;

    end;

   /*  trigger OnInsert()
    begin
        if "ID" = '' then
            "ID" := NoSeriesMgt.GetNextNo(GetNoSeriesCode());
    end; */

    var
        NoSeriesMgt: Codeunit "No. Series";
}
