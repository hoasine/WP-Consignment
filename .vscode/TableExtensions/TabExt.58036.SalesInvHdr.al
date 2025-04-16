tableextension 58036 SalesInvHdr extends "Sales Invoice Header"
{
    fields
    {
        field(58000; "Consign. Document No."; Code[20])
        {
            Caption = 'Consign. Document No.';
            TableRelation = "Consignment Header"."Document No.";
            DataClassification = ToBeClassified;
        }
    }
}

// tableextension 58038 SalesInvLine extends "Sales Invoice Line"
// {
//     fields
//     {
//         field(58000; "Contract ID"; Code[20])
//         {
//             Caption = 'Contract ID';
//             TableRelation = "Consignment Header"."Document No.";
//             DataClassification = ToBeClassified;
//         }
//     }
// }