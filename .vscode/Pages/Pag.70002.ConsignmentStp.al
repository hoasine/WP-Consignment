// page 70002 "Consignment Setup"
// {
//     PageType = ListPart;
//     SourceTable = "Consignment Setup";
//     DelayedInsert = true;

//     layout
//     {
//         area(Content)
//         {
//             repeater(GroupName)
//             {
//                 IndentationControls = "Hierarchy Type";
//                 IndentationColumn = NameIndent;
//                 field("Vendor No."; Rec."Vendor No.")
//                 {
//                     Visible = false;
//                     Style = Strong;
//                     StyleExpr = NoEmphasize;
//                     ApplicationArea = All;
//                 }
//                 field("Vendor Name"; Rec."Vendor Name")
//                 {
//                     Visible = false;
//                     ApplicationArea = All;
//                 }
//                 field("Hierarchy Type"; Rec."Hierarchy Type")
//                 {
//                     Style = Strong;
//                     StyleExpr = NoEmphasize;
//                     ApplicationArea = All;
//                 }
//                 field("Sub Type"; Rec."Sub Type")
//                 {
//                     Style = Strong;
//                     StyleExpr = NameEmphasize;
//                     ApplicationArea = All;
//                 }
//                 field("Starting Date"; Rec."Starting Date") { ApplicationArea = All; }
//                 field("Ending Date"; Rec."Ending Date") { ApplicationArea = All; }
//                 field("Consignment Type"; Rec."Consignment Type") { ApplicationArea = All; }
//                 field("Consignment Description"; Rec."Consignment Description") { ApplicationArea = All; }
//                 field("Promotion No."; Rec."Promotion No.") { ApplicationArea = All; }
//                 field("Promotion Description"; Rec."Promotion Description")
//                 {
//                     Caption = 'Description';
//                     ApplicationArea = All;
//                 }
//                 field("Line Disc. Pctg"; rec."Line Disc. Pctg.")
//                 {
//                     Caption = 'Line Disc. Pctg';
//                     ApplicationArea = All;
//                     Visible = false;
//                 }
//                 field("Periodic Discount Offer"; Rec."Periodic Discount Offer") { ApplicationArea = All; }
//                 field("Periodic Disc. Type"; Rec."Periodic Disc. Type") { ApplicationArea = All; }
//                 field("Periodic Discount Offer Desc."; Rec."Periodic Discount Offer Desc.")
//                 {
//                     Caption = 'Description';
//                     ApplicationArea = All;
//                 }
//                 field("Total Discount"; Rec."Total Discount") { ApplicationArea = All; }//20240513-+
//                 field("Total Discount Desc"; Rec."Total Discount Desc") { ApplicationArea = All; Caption = 'Description'; }//20240513-+
//                 field("Last Modified By"; Rec."Last Modified By") { ApplicationArea = All; }
//                 field("Last Modified Date"; Rec."Last Modified Date") { ApplicationArea = All; }
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action("Indent Hierarchy")
//             {
//                 Image = Indent;
//                 ApplicationArea = All;
//                 ToolTip = 'Indent consignment hierarchy to make the setup easier to read.';

//                 trigger OnAction()
//                 begin
//                     Rec.UpdateIndent(Rec."Vendor No.");
//                     CurrPage.Update(false);
//                     MESSAGE('Indentation Updated');
//                 end;
//             }
//         }
//     }

//     var
//         NameIndent: Integer;
//         NoEmphasize: Boolean;
//         NameEmphasize: Boolean;

//     trigger OnAfterGetRecord()
//     begin
//         NoEmphasize := (Rec."Hierarchy Type" <> Rec."Hierarchy Type"::Item);
//         NameIndent := Rec.Indentation;
//         NameEmphasize := (Rec."Hierarchy Type" <> Rec."Hierarchy Type"::Item);
//     end;

// }