table 70009 "Daily Consignment Checklist"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Daily Consignment Checklist";

    fields
    {
        field(1; "Document No."; Code[20]) { }

        field(10; "Generated Date Time"; DateTime) { }
    }

    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
        key(Key2; "Generated Date Time") { }
    }

    trigger OnInsert()
    begin
        Rec."Generated Date Time" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        rec."Generated Date Time" := CurrentDateTime;
    end;
}