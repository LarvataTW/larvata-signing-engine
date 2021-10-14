require "larvata/signing/engine"

module Larvata
  module Signing
    # 檢視簽呈提案資料
    mattr_accessor :admin_doc_url
    @@admin_doc_url = 'admin_doc_url'

    # 檢視簽呈資料
    mattr_accessor :admin_search_doc_url
    @@admin_search_doc_url = 'admin_search_doc_url'

    # 審批簽呈資料
    mattr_accessor :admin_signing_doc_url
    @@admin_signing_doc_url = 'admin_signing_doc_url'
  end
end
