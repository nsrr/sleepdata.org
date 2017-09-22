# frozen_string_literal: true

namespace :organizations do
  desc "Create the default BWH organization."
  task create_bwh: :environment do
    bwh = find_or_create_organization
    associate_datasets(bwh)
    create_legal_documents(bwh)
    migrate_old_agreements(bwh)
    assign_user_defaults
  end
end

def find_or_create_organization
  org_count = Organization.count
  bwh = Organization.where(slug: "bwh").first_or_create(name: "Brigham and Women's Hospital")
  if Organization.count > org_count
    puts " CREATED: #{bwh.name}"
  else
    puts "   FOUND: #{bwh.name}"
  end
  bwh
end

def associate_datasets(bwh)
  Dataset.where.not(slug: %w(learn wecare)).update_all organization_id: bwh.id
  puts "   ADDED: #{bwh.datasets.count} dataset#{"s" if bwh.datasets.count != 1} to #{bwh.name}"
end

def create_legal_documents(bwh)
  create_standard_i(bwh)
  create_standard_o(bwh)
  puts "   ADDED: #{bwh.legal_documents.count} legal document#{"s" if bwh.legal_documents.count != 1} to #{bwh.name}"
  assign_legal_docs_to_datasets(bwh)
  publish_legal_documents(bwh)
end

def migrate_old_agreements(bwh)
  puts "====TODO: Match existing agreements to legal doc formats"
  # TODO: Match existing agreements to legal doc formats
end

def assign_user_defaults
  puts "====TODO: Assign user defaults to commercial / non-commercial"
  # TODO: Assign user defaults to commercial / non-commercial
  puts "====TODO: Assign user defaults to individual / organization"
  # TODO: Assign user defaults to individual / organization
end

def create_standard_i(bwh)
  standard_i = bwh.legal_documents.where(slug: "standard-i").first_or_create(
    name: "Standard (Individual)",
    commercial_type: "both",
    data_user_type: "individual",
    attestation_type: "signature",
    approval_process: "committee"
  )

  standard_i.legal_document_pages.where(position: 1).first_or_create(
    title: "Data Access and Use Agreement",
    readable_content: "This Data Access and Use Agreement (the **\"DAUA\"**) is made by and between The Brigham and Women's Hospital, Inc., through its Division of Sleep and Circadian Disorders (**\"BWH\"**) and <full_name> (the **\"Data User\"**).\n\n**WHEREAS**, BWH is receiving support from the National Heart, Lung, and Blood Institute (**\"NHLBI\"**) to establish and operate a web-based collection of existing de-identified sleep study and related covariate data originating from past NHLBI-funded research studies (the **\"Data\"**), such collection known as the National Sleep Research Resource (**\"NSRR\"**); and\n\n**WHEREAS**, the purpose of the NSRR is to facilitate access to and use of the Data by third-party researchers to conduct sleep research in accordance with NHLBI and BWH policies and procedures (the **\"Purpose\"**); and\n\n**WHEREAS**, to the extent permitted by its Institutional Review Board and institutional policies, BWH wishes to make the Data, in the form of one or more **\"Datasets\"**, available to Data User, and Data User wishes to receive the Datasets, for this Purpose under the terms and conditions of access set forth herein;\n\n**NOW**, **THEREFORE**, in consideration of the mutual promises and covenants set forth below, the parties hereby agree as follows:\n\n<institution>\n\n<professional_title>\n\n<telephone>\n\n<email>\n\n<address:text>"
  )

  standard_i.legal_document_variables.find_by(name: "professional_title").update(
    field_note: "Ex: Associate Professor, Data Manager, Student"
  )

  standard_i.legal_document_pages.where(position: 2).first_or_create(
    title: "Specific Purpose",
    readable_content: "2. Data User will describe to BWH via the electronic registration process for NSRR Data access at https://sleepdata.org the specific sleep research use for the Data / Datasets proposed by Data User (the **\"Specific Purpose\"**). The Specific Purpose as described in the online application process is:\n\n<project_title>\n\n<specific_purpose:text>\n\n<intended_use>\n\n<security:checkbox>\n\n<hipaa_training:checkbox>\n\nFor avoidance of doubt, permissible uses may include use of the Data / Datasets for research evaluation and testing of a product or technology but will not extend to proposals that include or incorporate the Data / Datasets into such product. BWH will provide the Data / Datasets requested by the Data User upon BWH's approval, in its sole discretion, of the Specific Purpose, its receipt of this DAUA signed by Data User (or of Data User's Duly Authorized Representative, if an organization), and the submission by Data User of any additional information or documentation required by NSRR policies and procedures as applicable to the request (including, when required, submission of evidence of approval of the Specific Purpose by Data User's Institutional Review Board). The requirements described in this Section 2 will apply regardless of whether Data User has been previously approved by NHLBI to access complementary data from databases or other resources controlled by NHLBI (including but not limited to BioLINCC). Data User acknowledges that other researchers are permitted to access the Data / Dataset on the same terms as Data User, so that duplication of research may occur."
  )

  standard_i.legal_document_variables.find_by(name: "security").update(
    description: "I attest that data will be stored on a secure password protected device."
  )

  standard_i.legal_document_variables.find_by(name: "hipaa_training").update(
    description: "I attest that I have completed a Human Subjects Protections Training Course."
  )

  standard_i.legal_document_pages.where(position: 3).first_or_create(
    title: "Data Access and Use Agreement",
    readable_content: "3. Any Data/Datasets provided to Data User under this DAUA will be De-Identified within the meaning of the Health Insurance Portability and Accountability Act of 1996 privacy regulations (**\"HIPAA\"**). Data User agrees that Data User will not attempt to identify or re-identify any individual patient/research subject or group of patients/research subjects from the Data / Datasets.\n\n4. Data User agrees that Data User will use the Data / Datasets solely for the Specific Purpose and for no other purpose. Substantive modifications to the Specific Purpose will require submission of an amendment to the original access request and be subject to new approval pursuant to the process described in Section 2.\n\n5. Data User agrees that Data User will not disclose, disseminate, or otherwise share the Data / Datasets to or with any other person or entity other than the persons or entities identified to BWH on its application for NSRR Data access, for any purpose, without the prior written consent of BWH. Data User will ensure that any permitted third parties who are not under its direct control and who will have access to the Data / Datasets agree in writing to all of the same terms, conditions and obligations that apply to Data User with respect to the Data / Datasets, and will make BWH a third-party beneficiary of such agreement. For avoidance of doubt, although Data User may publish or present the results of any research analysis conducted by it as part of the Specific Purpose, Data User may NOT include the Data / Datasets, or any elements, parts or excerpts thereof, in any publication or presentation without the express prior written consent of BWH to such inclusion.\n\n6. If the Data User determines that it is Required by Law (as that term is defined in the HIPAA privacy regulations) to use or disclose the Data / Datasets other than as provided for in this DAUA, it shall provide prompt written notice of such determination to BWH so that BWH may have an opportunity to take measures to protect the Data / Datasets as appropriate.\n\n7. Data User will use appropriate safeguards, including information security controls, to prevent use or disclosure of the Data / Datasets other than as provided for by this DAUA, and Data User will report immediately to BWH in writing any use or disclosure not provided for by this DAUA of which it becomes aware.\n\n8. Upon the expiration or earlier termination of this DAUA as provided in Section 14 below, the Data User shall cease using the Data / Datasets and shall destroy (or return if so requested by BWH) all of the Data / Datasets received in tangible form, including notes, reports, and other information to the extent it contains the Data / Datasets, and shall keep no copies, except to the extent specifically Required by Law(s) made known to BWH by the Data User.\n\n9. THE DATA / DATASETS AND ALL OTHER MATERIALS, TOOLS OR CONTENT ON HTTPS://SLEEPDATA.ORG ARE PROVIDED \"AS IS.\" BWH MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING THE DATA/DATASETS OR MATERIALS, TOOLS OR CONTENT, OR THE RIGHTS GRANTED HEREIN, INCLUDING, WITHOUT LIMITATION, WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NONINFRINGEMENT, AND THE ABSENCE OF LATENT OR OTHER DEFECTS, WHETHER OR NOT DISCOVERABLE, AND HEREBY DISCLAIMS THE SAME.\n\n10. IN NO EVENT SHALL BWH OR ANY OF BWH'S RESPECTIVE TRUSTEES, DIRECTORS, OFFICERS, MEDICAL OR PROFESSIONAL STAFF, EMPLOYEES AND AGENTS BE LIABLE TO THE DATA USER FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE OR CONSEQUENTIAL DAMAGES OF ANY KIND ARISING IN ANY WAY OUT OF THIS DAUA OR RIGHTS GRANTED HEREIN, HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, INCLUDING WITHOUT LIMITATION, ECONOMIC DAMAGES OR INJURY TO PROPERTY OR LOST PROFITS, REGARDLESS OF WHETHER BWH SHALL BE ADVISED, SHALL HAVE OTHER REASON TO KNOW, OR IN FACT SHALL KNOW OF THE POSSIBILITY OF THE FOREGOING.\n\n11. Data User agrees not to use the name or logo of BWH or any of its affiliates or any of their respective trustees, directors, officers, staff members, employees, students or agents for any purpose without BWH's prior written approval; provided, however, that Data User will acknowledge the NSRR as the resource through which the Data / Datasets were obtained in any publication or presentation arising from the Specific Purpose. At Data User's option, BWH may post a summary of Data User's Specific Purpose and/or Data User's name on https://sleepdata.org for the purpose of providing information about the projects and users of the NSRR.\n\n<posting_permission>\n\n12. This DAUA shall become effective upon the date of BWH's release of Data / Datasets to Data User (**\"Effective Date\"**) and shall expire upon the earlier of (i) three (3) years after the Effective Date or (ii) Data User's cessation or completion of the Specific Purpose (as applicable, the **\"Initial Term\"**). If Data User continues to desire access to the Data / Datasets for the Specific Purpose beyond the Initial Term, Data User may submit a request for continued access and an extension of this DAUA to BWH. BWH may terminate the DAUA and Data User's access to Data / Datasets hereunder at any time during the Initial Term or any subsequent term, and for any reason, upon written notice to the Data User.\n\n13. To the extent Data User is permitted under the terms of this DAUA to retain any portion of the Data / Dataset, or any copies thereof, upon the expiration or termination of the DAUA, the Data User's obligations under the DAUA with respect to such Data / Datasets shall survive such expiration or termination for as long as Data User retains the Data / Datasets.\n\n14. This DAUA may be modified or amended only in a writing signed by duly authorized representatives of both the Data User (where Data User is an organization) and BWH. This DAUA shall be governed by and construed in accordance with the laws of the Commonwealth of Massachusetts. Any claim or action brought under this DAUA shall be brought in the federal or state courts of Massachusetts.\n\n15. All notices required by this DAUA shall be provided to the signatory for each party at the address identified below.\n\n16. In all publications and other citations that use resources made available through the sleepdata.org site, User agrees to acknowledge the appropriate grants and references for individual cohort data downloaded as indicated in the citation section on the relevant NSRR web page, along with the following:\n\n<p class=\"text-center\">\nNSRR R24 HL114473: NHLBI National Sleep Research Resource.\n</p>\n\n17. Sections 3 through 11 and Sections 13, 14, 15, and 16 of this DAUA shall survive its expiration or termination.\n\n<terms_and_conditions:checkbox>"
  )

  standard_i.legal_document_variables.find_by(name: "terms_and_conditions").update(
    description: "I have read and fully understand and accept the above terms and conditions."
  )
end

def create_standard_o(bwh)
  standard_o = bwh.legal_documents.where(slug: "standard-o").first_or_create(
    name: "Standard (Organization)",
    commercial_type: "both",
    data_user_type: "organization",
    attestation_type: "signature",
    approval_process: "committee"
  )

  standard_o.legal_document_pages.where(position: 1).first_or_create(
    title: "Data Access and Use Agreement",
    readable_content: "This Data Access and Use Agreement (the **\"DAUA\"**) is made by and between The Brigham and Women's Hospital, Inc., through its Division of Sleep and Circadian Disorders (**\"BWH\"**) and <organization_name> (the **\"Data User\"**).\n\n**WHEREAS**, BWH is receiving support from the National Heart, Lung, and Blood Institute (**\"NHLBI\"**) to establish and operate a web-based collection of existing de-identified sleep study and related covariate data originating from past NHLBI-funded research studies (the **\"Data\"**), such collection known as the National Sleep Research Resource (**\"NSRR\"**); and\n\n**WHEREAS**, the purpose of the NSRR is to facilitate access to and use of the Data by third-party researchers to conduct sleep research in accordance with NHLBI and BWH policies and procedures (the **\"Purpose\"**); and\n\n**WHEREAS**, to the extent permitted by its Institutional Review Board and institutional policies, BWH wishes to make the Data, in the form of one or more **\"Datasets\"**, available to Data User, and Data User wishes to receive the Datasets, for this Purpose under the terms and conditions of access set forth herein;\n\n**NOW**, **THEREFORE**, in consideration of the mutual promises and covenants set forth below, the parties hereby agree as follows:\n\n<contact_name>\n\n<contact_title>\n\n<contact_telephone>\n\n<contact_email>\n\n<organization_address:text>"
  )

  standard_o.legal_document_variables.find_by(name: "contact_title").update(
    field_note: "Ex: Associate Professor, Data Manager, Student"
  )

  standard_o.legal_document_pages.where(position: 2).first_or_create(
    title: "Specific Purpose",
    readable_content: "2. Data User will describe to BWH via the electronic registration process for NSRR Data access at https://sleepdata.org the specific sleep research use for the Data / Datasets proposed by Data User (the **\"Specific Purpose\"**). The Specific Purpose as described in the online application process is:\n\n<project_title>\n\n<specific_purpose:text>\n\n<intended_use>\n\n<security:checkbox>\n\n<hipaa_training:checkbox>\n\nFor avoidance of doubt, permissible uses may include use of the Data / Datasets for research evaluation and testing of a product or technology but will not extend to proposals that include or incorporate the Data / Datasets into such product. BWH will provide the Data / Datasets requested by the Data User upon BWH's approval, in its sole discretion, of the Specific Purpose, its receipt of this DAUA signed by Data User (or of Data User's Duly Authorized Representative, if an organization), and the submission by Data User of any additional information or documentation required by NSRR policies and procedures as applicable to the request (including, when required, submission of evidence of approval of the Specific Purpose by Data User's Institutional Review Board). The requirements described in this Section 2 will apply regardless of whether Data User has been previously approved by NHLBI to access complementary data from databases or other resources controlled by NHLBI (including but not limited to BioLINCC). Data User acknowledges that other researchers are permitted to access the Data / Dataset on the same terms as Data User, so that duplication of research may occur."
  )

  standard_o.legal_document_variables.find_by(name: "security").update(
    description: "I attest that data will be stored on a secure password protected device."
  )

  standard_o.legal_document_variables.find_by(name: "hipaa_training").update(
    description: "I attest that I have completed a Human Subjects Protections Training Course."
  )

  standard_o.legal_document_pages.where(position: 3).first_or_create(
    title: "Data Access and Use Agreement",
    readable_content: "3. Any Data/Datasets provided to Data User under this DAUA will be De-Identified within the meaning of the Health Insurance Portability and Accountability Act of 1996 privacy regulations (**\"HIPAA\"**). Data User agrees that Data User will not attempt to identify or re-identify any individual patient/research subject or group of patients/research subjects from the Data / Datasets.\n\n4. Data User agrees that Data User will use the Data / Datasets solely for the Specific Purpose and for no other purpose. Substantive modifications to the Specific Purpose will require submission of an amendment to the original access request and be subject to new approval pursuant to the process described in Section 2.\n\n5. Data User agrees that Data User will not disclose, disseminate, or otherwise share the Data / Datasets to or with any other person or entity other than the persons or entities identified to BWH on its application for NSRR Data access, for any purpose, without the prior written consent of BWH. Data User will ensure that any permitted third parties who are not under its direct control and who will have access to the Data / Datasets agree in writing to all of the same terms, conditions and obligations that apply to Data User with respect to the Data / Datasets, and will make BWH a third-party beneficiary of such agreement. For avoidance of doubt, although Data User may publish or present the results of any research analysis conducted by it as part of the Specific Purpose, Data User may NOT include the Data / Datasets, or any elements, parts or excerpts thereof, in any publication or presentation without the express prior written consent of BWH to such inclusion.\n\n6. If the Data User determines that it is Required by Law (as that term is defined in the HIPAA privacy regulations) to use or disclose the Data / Datasets other than as provided for in this DAUA, it shall provide prompt written notice of such determination to BWH so that BWH may have an opportunity to take measures to protect the Data / Datasets as appropriate.\n\n7. Data User will use appropriate safeguards, including information security controls, to prevent use or disclosure of the Data / Datasets other than as provided for by this DAUA, and Data User will report immediately to BWH in writing any use or disclosure not provided for by this DAUA of which it becomes aware.\n\n8. Upon the expiration or earlier termination of this DAUA as provided in Section 14 below, the Data User shall cease using the Data / Datasets and shall destroy (or return if so requested by BWH) all of the Data / Datasets received in tangible form, including notes, reports, and other information to the extent it contains the Data / Datasets, and shall keep no copies, except to the extent specifically Required by Law(s) made known to BWH by the Data User.\n\n9. THE DATA / DATASETS AND ALL OTHER MATERIALS, TOOLS OR CONTENT ON HTTPS://SLEEPDATA.ORG ARE PROVIDED \"AS IS.\" BWH MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING THE DATA/DATASETS OR MATERIALS, TOOLS OR CONTENT, OR THE RIGHTS GRANTED HEREIN, INCLUDING, WITHOUT LIMITATION, WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NONINFRINGEMENT, AND THE ABSENCE OF LATENT OR OTHER DEFECTS, WHETHER OR NOT DISCOVERABLE, AND HEREBY DISCLAIMS THE SAME.\n\n10. IN NO EVENT SHALL BWH OR ANY OF BWH'S RESPECTIVE TRUSTEES, DIRECTORS, OFFICERS, MEDICAL OR PROFESSIONAL STAFF, EMPLOYEES AND AGENTS BE LIABLE TO THE DATA USER FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE OR CONSEQUENTIAL DAMAGES OF ANY KIND ARISING IN ANY WAY OUT OF THIS DAUA OR RIGHTS GRANTED HEREIN, HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, INCLUDING WITHOUT LIMITATION, ECONOMIC DAMAGES OR INJURY TO PROPERTY OR LOST PROFITS, REGARDLESS OF WHETHER BWH SHALL BE ADVISED, SHALL HAVE OTHER REASON TO KNOW, OR IN FACT SHALL KNOW OF THE POSSIBILITY OF THE FOREGOING.\n\n11. Data User shall indemnify, defend and hold harmless BWH and its affiliates and their respective trustees, directors, officers, medical and professional staff, employees, and agents and their respective successors, heirs and assigns (the **\"Indemnities\"**), against any liability, damage, loss or expense (including reasonable attorneys' fees and expenses of litigation) incurred by or imposed upon the Indemnitees or any one of them in connection with any claims, suits, actions, demands or judgments arising out of any theory of product liability (including, but not limited to, actions in the form of contract, tort, warranty, or strict liability) concerning any product, tool, technology, process or service made, used, or sold or performed pursuant to any right granted under this DAUA. Data User agrees, at its own expense, to provide attorneys reasonably acceptable to BWH to defend against any actions brought or filed against any party indemnified hereunder with respect to the subject of indemnity contained herein, whether or not such actions are rightfully brought; provided, however, that any Indemnitee shall have the right to retain its own counsel, at the expense of Data User, if representation of such Indemnitee by counsel retained by Data User would be inappropriate because of conflict of interests of such Indemnitee and any other party represented by such counsel. Data User agrees to keep BWH informed of the progress in the defense and disposition of such claim and to consult with BWH prior to any proposed settlement.\n\n12. Data User shall maintain insurance sufficient to meet its obligations under Section 11 of this DAUA.\n\n13. Data User agrees not to use the name or logo of BWH or any of its affiliates or any of their respective trustees, directors, officers, staff members, employees, students or agents for any purpose without BWH's prior written approval; provided, however, that Data User will acknowledge the NSRR as the resource through which the Data / Datasets were obtained in any publication or presentation arising from the Specific Purpose. At Data User's option, BWH may post a summary of Data User's Specific Purpose and/or Data User's name on https://sleepdata.org for the purpose of providing information about the projects and users of the NSRR.\n\n<posting_permission>\n\n14. This DAUA shall become effective upon the date of BWH's release of Data / Datasets to Data User (**\"Effective Date\"**) and shall expire upon the earlier of (i) three (3) years after the Effective Date or (ii) Data User's cessation or completion of the Specific Purpose (as applicable, the **\"Initial Term\"**). If Data User continues to desire access to the Data / Datasets for the Specific Purpose beyond the Initial Term, Data User may submit a request for continued access and an extension of this DAUA to BWH. BWH may terminate the DAUA and Data User's access to Data / Datasets hereunder at any time during the Initial Term or any subsequent term, and for any reason, upon written notice to the Data User.\n\n15. To the extent Data User is permitted under the terms of this DAUA to retain any portion of the Data / Dataset, or any copies thereof, upon the expiration or termination of the DAUA, the Data User's obligations under the DAUA with respect to such Data / Datasets shall survive such expiration or termination for as long as Data User retains the Data / Datasets.\n\n16. This DAUA may be modified or amended only in a writing signed by duly authorized representatives of both the Data User (where Data User is an organization) and BWH. This DAUA shall be governed by and construed in accordance with the laws of the Commonwealth of Massachusetts. Any claim or action brought under this DAUA shall be brought in the federal or state courts of Massachusetts.\n\n17. All notices required by this DAUA shall be provided to the signatory for each party at the address identified below.\n\n18. In all publications and other citations that use resources made available through the sleepdata.org site, User agrees to acknowledge the appropriate grants and references for individual cohort data downloaded as indicated in the citation section on the relevant NSRR web page, along with the following:\n\n<p class=\"text-center\">\nNSRR R24 HL114473: NHLBI National Sleep Research Resource.\n</p>\n\n19. Sections 3 through 13 and Sections 15, 16, 17, and 18 of this DAUA shall survive its expiration or termination.\n\n<terms_and_conditions:checkbox>"
  )

  standard_o.legal_document_variables.find_by(name: "terms_and_conditions").update(
    description: "I have read and fully understand and accept the above terms and conditions."
  )
end

def assign_legal_docs_to_datasets(bwh)
  legal_documents = bwh.legal_documents.where(slug: %w(standard-i standard-o))
  bwh.datasets.each do |dataset|
    legal_documents.each do |legal_document|
      bwh.legal_document_datasets.where(
        legal_document_id: legal_document.id,
        dataset_id: dataset.id
      ).first_or_create
    end
  end
  puts "   ADDED: #{legal_documents.count} legal document#{"s" if legal_documents.count != 1} to #{bwh.datasets.count} dataset#{"s" if bwh.datasets.count != 1}"
end

def publish_legal_documents(bwh)
  puts "====TODO: Publish legal docs"
  # TODO: Publish legal docs
end
