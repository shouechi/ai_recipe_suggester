class RecipesController < ApplicationController
  def new
     # newアクションでも@recipeを初期化しておくと、ビューでの条件分岐がシンプルになる
    @recipe = nil
  end

  def create
    # 1. フォームから食材の文字列を受け取る
    ingredients = params[:ingredients]

    # 2. AIへの指示（プロンプト）を作成する。今回はJSON形式での出力を厳密に指示する。
    prompt = <<-PROMPT
    「#{ingredients}」という食材を使った、家庭で簡単に作れるレシピを1つ提案してください。
    以下のJSON形式で、キーや値の型も完全に守って応答してください。

    {
      "recipeName": "料理名",
      "description": "料理の簡単な説明",
      "ingredients": [
        { "name": "材料名", "quantity": "分量" }
      ],
      "instructions": [
        "手順1",
        "手順2"
      ]
    }
    PROMPT

    # 3. OpenAI APIクライアントを初期化する
    client = OpenAI::Client.new

    # 4. APIにリクエストを送信する。JSONモードを有効にする。
    begin
      response = client.chat(
        parameters: {
          # model: 使用するAIモデルを指定します。
          # "gpt-4o-mini"は、高速かつ低コストでありながら高い性能を持つ最新モデルの一つです。
          model: "gpt-4o-mini",

          # messages: AIに渡す指示や会話の履歴を配列で指定します。
          # role: "user"は、ユーザーからの発言であることを示します。
          # content: ここに具体的な指示（プロンプト）を渡します。
          messages: [{ role: "user", content: prompt }],

          # response_format: AIの応答形式を指定します。
          # { type: "json_object" }とすることで、AIは必ず有効なJSONオブジェクトを返すようになります。
          response_format: { type: "json_object" },

          # temperature: 応答のランダム性（創造性）を制御します。0に近いほど決定的で、2に近いほど多様な応答になります。
          # 0.7は、ある程度の創造性を保ちつつ、安定した応答を得やすい一般的な値です。
          temperature: 0.7,
        }
      )
      # 5. AIからのJSON応答をパースし、インスタンス変数に格納する
      raw_response = response.dig("choices", 0, "message", "content")
      @recipe = JSON.parse(raw_response)
    rescue OpenAI::Error => e
      #APIエラーが発生した際の処理
      @error_message = "AIとの通信中にエラーが発生しました: #{e.message}"
    rescue JSON::ParserError => e
      #JSONのパースに失敗した際の処理
      @error_message = "AIからの応答を正しく解析できませんでした。もう一度お試しください。"
    end





    # createアクションの後、newテンプレートを再描画する
    # これにより、@recipe変数がnew.html.erbで使えるようになる
    render :new, status: :ok
  end
end
