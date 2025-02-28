// page 70001 "Consignment Rate"
// {
//     PageType = ListPart;
//     SourceTable = "Consignment Rate";
//     DelayedInsert = true;
//     AdditionalSearchTerms = 'Consignment';

//     layout
//     {
//         area(Content)
//         {
//             repeater(GroupName)
//             {
//                 field("Consignment Type"; Rec."Consignment Type") { ApplicationArea = All; Style = Strong; StyleExpr = true; ShowMandatory = true; }
//                 field(Description; Rec.Description) { ApplicationArea = All; }
//                 field("Starting Date"; Rec."Starting Date") { ApplicationArea = All; ShowMandatory = true; }
//                 field("Ending Date"; Rec."Ending Date") { ApplicationArea = All; ShowMandatory = true; }
//                 field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; Visible = false; }
//                 field("Vendor Name"; Rec."Vendor Name") { ApplicationArea = All; Visible = false; }
//                 field("Store No."; Rec."Store No.") { ApplicationArea = All; }
//                 field("Store Name"; Rec."Store Name") { ApplicationArea = All; }
//                 field("Consignment %"; Rec."Consignment %") { ApplicationArea = All; }
//                 field("Last Modified By"; Rec."Last Modified By") { ApplicationArea = All; }
//                 field("Last Modified Date"; Rec."Last Modified Date") { ApplicationArea = All; }
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action("Copy Consignment Setup")
//             {
//                 ApplicationArea = All;
//                 Image = CopyToTask;

//                 trigger OnAction()
//                 begin
//                     CopyConsignmentStp();
//                 end;
//             }
//         }
//     }

//     local procedure CopyConsignmentStp()
//     var
//         rptCopyConsign: Report "Copy Consig. Setup from Vendor";
//     begin
//         Clear(rptCopyConsign);
//         rptCopyConsign.AssignParam(Rec."Vendor No.");
//         rptCopyConsign.Run();
//     end;
// }