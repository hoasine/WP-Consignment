page 70017 "Daily Consign. Checklist Card"
{
    Caption = 'Daily Consignment Checklist';
    PageType = Card;
    SourceTable = "Daily Consignment Checklist";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(ConsignmentByDate)
            {
                Caption = 'Consignment By Date';
                Editable = false;

                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("Generated Date Time"; Rec."Generated Date Time") { ApplicationArea = All; }

            }
            part(consignmentSalesDetailsPart; "Daily Consign Checklist Det.")
            {
                Caption = 'Consignment Sales Lines';
                ApplicationArea = All;
                SubPageLink = "Document No." = field("Document No.");
                Editable = false;
                ShowFilter = true;
            }
            part(consignsalesMissingDetailsPart; "Daily Consig Checklist Missing")
            {
                Caption = 'Consignment Sales Missing Lines';
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Document No." = field("Document No.");
                ShowFilter = true;
            }

        }
    }

}