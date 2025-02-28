page 70016 "Daily Consignment Checklist"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Daily Consignment Checklist";
    CardPageId = "Daily Consign. Checklist Card";
    SourceTableView = sorting("Generated Date Time") order(descending);
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document No."; Rec."Document No.") { }
                field("Generated Date Time"; Rec."Generated Date Time") { }
            }
        }
    }
}