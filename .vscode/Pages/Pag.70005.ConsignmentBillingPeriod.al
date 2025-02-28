
//001   EDO 20230529    HIDE ENTRY NO. 
//002   EDO 20230529    DISPLAY BATCH DONE TIMESTAMP FIELD


// page 70005 ConsignmentBillingPeriod
// {
//     ApplicationArea = All;
//     Caption = 'xConsignment Billing Period';
//     PageType = List;
//     SourceTable = "Consignment Billing Period";
//     UsageCategory = Administration;
//     ObsoleteState = Pending;
//     ObsoleteReason = 'This page is replaced by Consigment Billing Periods page 70026.';

//     layout
//     {
//         area(content)
//         {
//             repeater(General)
//             {
//                 field("Entry No."; Rec."Entry No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Entry No. field.';
//                     Visible = false; //001
//                 }
//                 field("Start Period"; Rec."Start Period")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Start Period field.';
//                 }
//                 field("End Period"; Rec."End Period")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the End Period field.';
//                 }
//                 field("Billing Cut-off Date"; Rec."Billing Cut-off Date")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Billing Cut-off Date field.';
//                 }
//                 field("Confirm Email"; Rec."Confirm Email")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Confirm Email field.';
//                 }
//                 field("Batch is done"; rec."Batch is done")
//                 {
//                     ApplicationArea = all;
//                 }
//                 //002-
//                 field("Batch Timestamp"; Rec."Batch Timestamp")
//                 {
//                     ApplicationArea = ALL;
//                     Editable = FALSE;
//                 }
//                 //002+
//             }
//         }
//     }
// }
