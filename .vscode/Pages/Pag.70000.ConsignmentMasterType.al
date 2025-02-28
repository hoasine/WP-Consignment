page 70000 "Consignment Master Type"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Consignment Type";
    AdditionalSearchTerms = 'Consignment,Master';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code) { ShowMandatory = true; }
                field(Description; Rec.Description) { ShowMandatory = true; }
                field("Last Modified By"; Rec."Last Modified By") { }
                field("Last Modified Date"; Rec."Last Modified Date") { }
            }
        }
        area(Factboxes)
        {
            systempart(Notes; Notes) { }
        }
    }
}