page 70009 "Consignment Document Lines"
{
    Caption = 'Consignment Document Lines';
    PageType = ListPart;
    SourceTable = "Consignment Entries";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Date"; Rec."Date") { ApplicationArea = All; ToolTip = 'Specifies the value of the Date field.'; }
                field("Store No."; Rec."Store No.") { ApplicationArea = All; ToolTip = 'Specifies the value of the Store No. field.'; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; ToolTip = 'Specifies the value of the Vendor No. field.'; }
                field(Division; Rec.Division) { ApplicationArea = All; ToolTip = 'Specifies the value of the Division field.'; }
                field("Item Category"; Rec."Item Category") { ApplicationArea = All; ToolTip = 'Specifies the value of the Item Category field.'; }
                field("Item Category Description"; Rec."Item Category Description") { ApplicationArea = All; ToolTip = 'Specifies the value of the Item Category Description field.'; }
                field("Product Group"; Rec."Product Group") { ApplicationArea = All; ToolTip = 'Specifies the value of the Product Group field.'; }
                field("Product Group Description"; Rec."Product Group Description") { ApplicationArea = All; ToolTip = 'Specifies the value of the Product Group Description field.'; }
                field("Special Group"; Rec."Special Group") { ApplicationArea = All; ToolTip = 'Specifies the value of the Special Group field.'; }
                field("Special Group Description"; Rec."Special Group Description") { ApplicationArea = All; ToolTip = 'Specifies the value of the Special Group Description field.'; }
                field("Special Group 2"; Rec."Special Group 2") { ApplicationArea = All; ToolTip = 'Specifies the value of the Special Group field.'; }//20240513-+
                field("Special Group 2 Description"; Rec."Special Group 2 Description") { ApplicationArea = All; ToolTip = 'Specifies the value of the Special Group Description field.'; }//20240513-+
                field("Item No."; Rec."Item No.") { ApplicationArea = All; ToolTip = 'Specifies the value of the Item No. field.'; }
                field("Item Description"; Rec."Item Description") { ApplicationArea = All; ToolTip = 'Specifies the value of the Item Description field.'; }
                field("Promotion No."; Rec."Promotion No.") { ApplicationArea = All; ToolTip = 'Specifies the value of the Promotion No. field.'; }
                field("Periodic Disc. Type"; Rec."Periodic Disc. Type") { ApplicationArea = All; ToolTip = 'Specifies the value of the Periodic Disc. Type field.'; }
                field("Periodic Offer No."; Rec."Periodic Offer No.") { ApplicationArea = All; ToolTip = 'Specifies the value of the Periodic Offer No. field.'; }
                field("Total Discount"; Rec."Total Discount") { ApplicationArea = All; }//20240513-+
                field("Total Discount Desc"; Rec."Total Discount Desc") { ApplicationArea = All; }//20240513-+
                field("Discount Amount"; Rec."Discount Amount") { ApplicationArea = All; ToolTip = 'Specifies the value of the Discount Amount field.'; }
                field("Total Excl Tax"; Rec."Total Excl Tax") { ApplicationArea = All; ToolTip = 'Specifies the value of the Total Excl Tax field.'; }
                field("VAT Amount"; Rec."VAT Amount") { ApplicationArea = All; ToolTip = 'Specifies the value of the VAT Amount field.'; }
                field("Total Incl Tax"; Rec."Total Incl Tax") { ApplicationArea = All; ToolTip = 'Specifies the value of the Total Incl Tax field.'; }
                field("Consignment Type"; Rec."Consignment Type") { ApplicationArea = All; ToolTip = 'Specifies the value of the Consignment Type field.'; }
                field("Consignment %"; Rec."Consignment %") { ApplicationArea = All; ToolTip = 'Specifies the value of the GP % field.'; }
                field("Cost Incl Tax"; Rec."Cost Incl Tax") { ApplicationArea = All; ToolTip = 'Specifies the value included Tax'; }
                field("Applied to Billing Line No."; Rec."Applied to Billing Line No.") { ApplicationArea = All; ToolTip = 'Specifies the value of the Applied to Billing Line No. field.'; }
                field("Receipt No."; Rec."Receipt No.") { ApplicationArea = All; ToolTip = 'Specifies the value of the Receipt No. field.'; }
                field("MDR Rate Pctg"; Rec."MDR Rate Pctg") { DecimalPlaces = 0 : 3; ; ApplicationArea = All; ToolTip = 'Specifies the value of the MDR Rate Pctg field.'; }
                field("MDR Weight"; Rec."MDR Weight") { DecimalPlaces = 0 : 3; ApplicationArea = All; ToolTip = 'Specifies the value of the MDR Weight field.'; }
                field("MDR Amount"; Rec."MDR Amount") { ApplicationArea = All; ToolTip = 'Specifies the value of the MDR Amount field.'; }
            }
        }
    }
}
