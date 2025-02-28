table 70000 "Consignment Type"
{
    DataCaptionFields = code, description;
    LookupPageId = "Consignment Master Type";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(10; "Description"; Text[50]) { }
        field(50; "Last Modified By"; Code[50])
        {
            Editable = false;
        }
        field(51; "Last Modified Date"; DateTime)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Last Modified By" := UserId;
        "Last Modified Date" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Modified By" := UserId;
        "Last Modified Date" := CurrentDateTime;
    end;
}