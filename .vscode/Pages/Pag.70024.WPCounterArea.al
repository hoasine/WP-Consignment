page 70024 "WP Counter Area"
{
    ApplicationArea = All;
    Caption = 'Counter Area';
    PageType = ListPart;
    SourceTable = "WP Counter Area";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.', Comment = '%';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("Store Description"; Rec."Store Description")
                {
                    ToolTip = 'Specifies the value of the Store Description field.', Comment = '%';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Starting Date field.', Comment = '%';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the Ending Date field.', Comment = '%';
                }
                field("Contract ID"; Rec."Contract ID")
                {
                    ToolTip = 'Specifies the value of the Contract ID field.', Comment = '%';
                }
                field("Contract Description"; Rec."Contract Description")
                {
                    ToolTip = 'Specifies the value of the Contract Description field.', Comment = '%';
                }
                field("Location ID"; Rec."Location ID")
                {
                    ToolTip = 'Specifies the value of the Location ID field.', Comment = '%';
                }
                field(Floor; Rec.Floor)
                {
                    ToolTip = 'Specifies the value of the Floor field.', Comment = '%';
                }
                field(Brand; Rec.Brand)
                {
                    ToolTip = 'Specifies the value of the Brand field.', Comment = '%';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.', Comment = '%';
                }


                field("Area"; Rec."Area")
                {
                    ToolTip = 'Specifies the value of the Area field.', Comment = '%';
                }
                field("VAT_Area"; Rec."VAT_Area")
                {
                    ToolTip = 'Specifies the value of the VAT_Area field.', Comment = '%';
                }
                field(Quantity_Area; Rec."Quantity_Area")
                {
                    ToolTip = 'Specifies the value of the Quantity_Area field.', Comment = '%';
                }
                field(UOM_Area; Rec."UOM_Area")
                {
                    ToolTip = 'Specifies the value of the UOM_Area field.', Comment = '%';
                }

                field("Amount"; Rec."Amount")
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field(VAT_Promotion; Rec."VAT_Promotion")
                {
                    ToolTip = 'Specifies the value of the VAT_Promotion field.', Comment = '%';
                }
                field(Quantity_Promotion; Rec."Quantity_Promotion")
                {
                    ToolTip = 'Specifies the value of the Quantity_Promotion field.', Comment = '%';
                }
                field(UOM_Promotion; Rec."UOM_Promotion")
                {
                    ToolTip = 'Specifies the value of the UOM_Promotion field.', Comment = '%';
                }
                field("Promotion"; Rec."Promotion")
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field(VAT_Parking; Rec."VAT_Parking")
                {
                    ToolTip = 'Specifies the value of the VAT_Parking field.', Comment = '%';
                }
                field(Quantity_Parking; Rec."Quantity_Parking")
                {
                    ToolTip = 'Specifies the value of the Quantity_Parking field.', Comment = '%';
                }
                field(UOM_Parking; Rec."UOM_Parking")
                {
                    ToolTip = 'Specifies the value of the UOM_Parking field.', Comment = '%';
                }
                field("Parking"; Rec."Parking")
                {
                    ToolTip = 'Specifies the value of the Packing field.', Comment = '%';
                }
                field(VAT_ST1; Rec."VAT_ST1")
                {
                    ToolTip = 'Specifies the value of the VAT_ST1 field.', Comment = '%';
                }
                field(Quantity_ST1; Rec."Quantity_ST1")
                {
                    ToolTip = 'Specifies the value of the Quantity_ST1 field.', Comment = '%';
                }
                field(UOM_ST1; Rec."UOM_ST1")
                {
                    ToolTip = 'Specifies the value of the UOM_ST1 field.', Comment = '%';
                }

                field("Storage1"; Rec."Storage1")
                {
                    ToolTip = 'Specifies the value of the Storage1 field.', Comment = '%';
                }
                field(VAT_ST2; Rec."VAT_ST2")
                {
                    ToolTip = 'Specifies the value of the VAT_ST2 field.', Comment = '%';
                }
                field(Quantity_ST2; Rec."Quantity_ST2")
                {
                    ToolTip = 'Specifies the value of the Quantity_ST2 field.', Comment = '%';
                }
                field(UOM_ST2; Rec."UOM_ST2")
                {
                    ToolTip = 'Specifies the value of the UOM_ST2 field.', Comment = '%';
                }
                field("Storage2"; Rec."Storage2")
                {
                    ToolTip = 'Specifies the value of the Storage2 field.', Comment = '%';
                }
                field(VAT_ST3; Rec."VAT_ST3")
                {
                    ToolTip = 'Specifies the value of the VAT_ST3 field.', Comment = '%';
                }
                field(Quantity_ST3; Rec."Quantity_ST3")
                {
                    ToolTip = 'Specifies the value of the Quantity_ST3 field.', Comment = '%';
                }
                field(UOM_ST3; Rec."UOM_ST3")
                {
                    ToolTip = 'Specifies the value of the UOM_ST3 field.', Comment = '%';
                }
                field("Storage3"; Rec."Storage3")
                {
                    ToolTip = 'Specifies the value of the Storage3 field.', Comment = '%';
                }
                field(VAT_ST4; Rec."VAT_ST4")
                {
                    ToolTip = 'Specifies the value of the VAT_ST4 field.', Comment = '%';
                }
                field(Quantity_ST4; Rec."Quantity_ST4")
                {
                    ToolTip = 'Specifies the value of the Quantity_ST4 field.', Comment = '%';
                }
                field(UOM_ST4; Rec."UOM_ST4")
                {
                    ToolTip = 'Specifies the value of the UOM_ST4 field.', Comment = '%';
                }
                field("Storage4"; Rec."Storage4")
                {
                    ToolTip = 'Specifies the value of the Storage4 field.', Comment = '%';
                }
                field(VAT_ST5; Rec."VAT_ST5")
                {
                    ToolTip = 'Specifies the value of the VAT_ST5 field.', Comment = '%';
                }
                field(Quantity_ST5; Rec."Quantity_ST5")
                {
                    ToolTip = 'Specifies the value of the Quantity_ST5 field.', Comment = '%';
                }
                field(UOM_ST5; Rec."UOM_ST5")
                {
                    ToolTip = 'Specifies the value of the UOM_ST5 field.', Comment = '%';
                }
                field("Storage5"; Rec."Storage5")
                {
                    ToolTip = 'Specifies the value of the Storage5 field.', Comment = '%';
                }
                field(VAT_Locker; Rec."VAT_Locker")
                {
                    ToolTip = 'Specifies the value of the VAT_Locker field.', Comment = '%';
                }
                field(Quantity_Locker; Rec."Quantity_Locker")
                {
                    ToolTip = 'Specifies the value of the Quantity_Locker field.', Comment = '%';
                }
                field(UOM_Locker; Rec."UOM_Locker")
                {
                    ToolTip = 'Specifies the value of the UOM_Locker field.', Comment = '%';
                }
                field("Locker"; Rec."Locker")
                {
                    ToolTip = 'Specifies the value of the Locker field.', Comment = '%';
                }
                field(VAT_Locker1; Rec."VAT_Locker1")
                {
                    ToolTip = 'Specifies the value of the VAT_Locker1 field.', Comment = '%';
                }
                field(Quantity_Locker1; Rec."Quantity_Locker1")
                {
                    ToolTip = 'Specifies the value of the Quantity_Locker1 field.', Comment = '%';
                }
                field(UOM_Locker1; Rec."UOM_Locker1")
                {
                    ToolTip = 'Specifies the value of the UOM_Locker1 field.', Comment = '%';
                }
                field("Locker1"; Rec."Locker1")
                {
                    ToolTip = 'Specifies the value of the Locke1 field.', Comment = '%';
                }
                field(VAT_Fixture; Rec."VAT_Fixture")
                {
                    ToolTip = 'Specifies the value of the VAT_Fixture field.', Comment = '%';
                }
                field(Quantity_Fixture; Rec."Quantity_Fixture")
                {
                    ToolTip = 'Specifies the value of the Quantity_Fixture field.', Comment = '%';
                }
                field(UOM_Fixture; Rec."UOM_Fixture")
                {
                    ToolTip = 'Specifies the value of the UOM_Fixture field.', Comment = '%';
                }
                field("Fixture"; Rec."Fixture")
                {
                    ToolTip = 'Specifies the value of the Fixture field.', Comment = '%';
                }
            }
        }
    }
}
