page 70015 "Consign. Sales Entries Lines"
{
    Caption = 'Consignment Sales Entries Lines';
    PageType = List;
    ApplicationArea = All;
    //UsageCategory = Administration;
    SourceTable = "Consignment Entries";
    SourceTableView = where("Document No." = filter(<> ''));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field(Date; Rec.Date) { }
                field("Store No."; Rec."Store No.") { }
                field("Vendor No."; Rec."Vendor No.") { }
                field(Division; Rec.Division) { }
                field("Item Category"; Rec."Item Category") { }
                field("Product Group"; Rec."Product Group") { }
                field("Special Group"; Rec."Special Group") { }
                field("Special Group 2"; Rec."Special Group 2") { }
                field("Item No."; Rec."Item No.") { }
                field("Item Description"; Rec."Item Description") { }
                field("Receipt No."; Rec."Receipt No.") { }
                field("Barcode No."; Rec."Barcode No.") { }
                field("Currency Code"; Rec."Currency Code") { }
                field("Exch. Rate"; Rec."Exch. Rate") { }
                field(Quantity; Rec.Quantity) { DecimalPlaces = 0 : 3; }
                field(Price; Rec.Price) { }
                field(UOM; Rec.UOM) { }
                field("Net Amount (LCY)"; Rec."Net Amount (LCY)") { }
                field("VAT per unit"; Rec."VAT per unit") { }
                field("VAT Amount (LCY)"; Rec."VAT Amount (LCY)") { }
                field("Cost Amount (LCY)"; Rec."Cost Amount (LCY)") { }
                field("Promotion No."; Rec."Promotion No.") { }
                field("Periodic Disc. Type"; Rec."Periodic Disc. Type") { }
                field("Periodic Offer No."; Rec."Periodic Offer No.") { }
                field("Periodic Discount Amount (LCY)"; Rec."Periodic Discount Amount (LCY)") { }
                field("VAT Code"; Rec."VAT Code") { }
                field("Gross Price"; Rec."Gross Price") { }
                field("Disc. Amount From Std. Price"; Rec."Disc. Amount From Std. Price") { Caption = 'Disc per unit'; }
                field("Discount Amount (LCY)"; Rec."Discount Amount (LCY)") { Caption = 'Discount Amount Excl. Tax'; }
                field("Net Price Incl Tax"; Rec."Net Price Incl Tax") { }
                field("Total Incl Tax"; Rec."Total Incl Tax") { }
                field(Tax; Rec.Tax * -1) { }
                field("Total Tax Collected"; Rec."Total Tax Collected" * -1) { }
                field("Net Price Excl Tax"; Rec."Net Price Excl Tax") { }
                field("Total Excl Tax"; Rec."Total Excl Tax") { }
                field(Cost; Rec.Cost) { }
                field("Consignment Amount"; Rec."Consignment Amount") { Caption = 'Profit Excl Tax'; }
                field("Consignment Amount (LCY)"; Rec."Consignment Amount (LCY)") { Caption = 'Profit (LCY)'; Visible = false; }
                field("Consignment %"; Rec."Consignment %") { }
                field("Return No Sales"; Rec."Return No Sales") { }
                field("Member Card No."; Rec."Member Card No.") { }
                field("Consignment Type"; Rec."Consignment Type") { }
                field("Created By"; Rec."Created By") { }
                field("Created Date"; Rec."Created Date") { }
                field("Item Family Code"; Rec."Item Family Code") { }
            }
        }
    }
}