//001   edo 20230529    Hide/Reveal fields according to Consignment Feedback document 20230508

pageextension 58061 RetailSetupExt extends "LSC Retail Setup"
{
    layout
    {
        addafter(Discounts)
        {
            //001-
            // group("Supplier Trading File Upload")
            // {
            //     field("Supplier Trading Batch ID"; Rec."Supplier Trading Batch ID")
            //     {
            //         ApplicationArea = all;
            //         Caption = 'Supplier Trading Batch ID';
            //         Description = 'Supplier Trading Batch ID';                    
            //     }
            // }
            //001+
            group("Consignment Master Setup")
            {
                field("Consignment Cycle"; Rec."Consignment Calc. Cycle") { Caption = 'Consignment Calc. Cycle'; ApplicationArea = All; }
                field("Consign. Calc. Start Date"; Rec."Consign. Calc. Start Date") { ApplicationArea = All; }
                field("Consign. Calc. Days/Months"; Rec."Consign. Calc. Days/Months") { ApplicationArea = All; }
                field("Consign. Calc. Daily"; Rec."Consign. Calc. Daily") { ApplicationArea = All; }
                field("Auto Post - PI"; Rec."Auto Post - PI") { ApplicationArea = all; }
                field("Auto Post - SI"; Rec."Auto Post - SI") { ApplicationArea = all; }
                field("Def. Purch. Inv. G/L Acc."; Rec."Def. Purch. Inv. G/L Acc.")
                {
                    ApplicationArea = all;
                    Caption = 'Def. Purch. Inv. G/L Acc.';
                    Description = 'Def. Purch. Inv. G/L Acc.';
                }
                field("Def. Sales Inv. G/L Acc."; Rec."Def. Sales Inv. G/L Acc.")
                {
                    ApplicationArea = all;
                    Caption = 'Def. Sales Inv. G/L Acc.';
                    Description = 'Def. Sales Inv. G/L Acc.';
                }
                field("Enable Auto E-Mail PI/SI"; Rec."Enable Auto E-Mail PI/SI")
                {
                    ApplicationArea = all;
                    Caption = 'Enable Auto E-Mail PI/SI';
                    Description = 'Enable Auto E-Mail PI/SI';
                }
                field("Scheduler Cut-off Date"; Rec."Scheduler Cut-off Date")
                {
                    ApplicationArea = all;
                    Caption = 'Scheduler Cut-off Date';
                    Description = 'Scheduler Cut-off Date';
                    Visible = false; //001
                }
                field("Consignment Attachment Path"; Rec."Consignment Attachment Path")
                {
                    ApplicationArea = all;
                    Caption = 'Consignment Attachment Path';
                    Description = 'Consignment Attachment Path';
                    Visible = false; //001
                    trigger OnValidate()
                    begin
                        if Rec."Consignment Attachment Path" <> '' then begin
                            Rec."Consignment Attachment Path" := delchr(Rec."Consignment Attachment Path", '>', '\');
                        end;
                    end;
                }
                field("Inventory Posting Groups"; Rec."Consign. Prod. Posting Groups")
                {
                    ApplicationArea = all;
                    caption = 'Consign. Prod. Posting Groups';
                    Description = 'Consign. Prod. Posting Groups';
                }
                field("Consignment Doc. Nos."; Rec."Consignment Doc. Nos.")
                {
                    ApplicationArea = All;
                }
                field(EmailBodyText; EmailBodyText)
                {
                    Caption = 'Consign. E-Mail Body Text';
                    MultiLine = true;
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Rec.SetEmailBodyText(EmailBodyText);
                    end;
                }
                //20240124-
                field("Def. Shortcut Dim. 1 - Sales"; Rec."Def. Shortcut Dim. 1 - Sales")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GeneralLegdSetup: Record "General Ledger Setup";
                        DefDim: Record "Default Dimension";
                        DimValue: Record "Dimension Value";
                    begin
                        GeneralLegdSetup.Get();
                        DimValue.Reset();
                        DimValue.SetRange("Dimension Code", GeneralLegdSetup."Global Dimension 1 Code");
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then
                            Rec."Def. Shortcut Dim. 1 - Sales" := DimValue.Code;
                    end;
                }
                field("Def. Shortcut Dim. 1 - Purch"; Rec."Def. Shortcut Dim. 1 - Purch")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GeneralLegdSetup: Record "General Ledger Setup";
                        DefDim: Record "Default Dimension";
                        DimValue: Record "Dimension Value";
                    begin
                        GeneralLegdSetup.Get();
                        DimValue.Reset();
                        DimValue.SetRange("Dimension Code", GeneralLegdSetup."Global Dimension 1 Code");
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then
                            Rec."Def. Shortcut Dim. 1 - Sales" := DimValue.Code;
                    end;
                }
                //20240124+
                field("TPR Batch Nos."; Rec."TPR Batch Nos.") { ApplicationArea = All; }
                field("Billing Period Nos."; Rec."Billing Period Nos.") { ApplicationArea = All; }
                field("Consign. Contract Nos."; Rec."Consign. Contract Nos.") { ApplicationArea = All; }
            }
        }

    }
    var
        EmailBodyText: Text;

    trigger OnAfterGetRecord()
    begin
        EmailBodyText := Rec.GetEmailBodyText();
    end;
}