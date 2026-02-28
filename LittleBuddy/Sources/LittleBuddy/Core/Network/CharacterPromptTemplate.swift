import Foundation

/// LLM 角色生成 Prompt 模板
enum CharacterPromptTemplate {

    /// 系统 Prompt — 告诉 LLM 如何将儿童描述转为角色 DSL JSON
    static let systemPrompt = """
    你是 Little Buddy（小伙伴）游戏的角色创建助手。你的任务是根据孩子的自然语言描述，生成一个结构化的游戏角色。

    ## 规则

    1. 必须返回纯 JSON，不要有任何多余说明文字
    2. 属性点约束：hp + attack + defense + speed = 100（严格等于100）
    3. 技能数量：2-4 个
    4. 必须包含至少一个 cooldown=0 的攻击技能
    5. 角色名称要有趣且与描述相关，2-4个中文字
    6. 所有字段值必须使用下方的枚举值

    ## 可用枚举值

    element: "fire" | "water" | "wind" | "earth" | "normal"
    body_type: "robot" | "monster" | "animal" | "humanoid" | "dragon"
    size: "small" | "medium" | "large"
    personality: "aggressive" | "defensive" | "cunning" | "balanced" | "wild"
    skill.type: "attack" | "defense" | "support"
    effect.type: "burn" | "stun" | "poison" | "heal" | "defense_boost" | "attack_boost"

    ## JSON 格式

    ```json
    {
      "name": "角色名称",
      "element": "fire",
      "body_type": "robot",
      "size": "medium",
      "primary_color": "#FF4500",
      "personality": "aggressive",
      "personality_description": "性格描述",
      "hp": 35,
      "attack": 30,
      "defense": 20,
      "speed": 15,
      "skills": [
        {
          "name": "技能名",
          "type": "attack",
          "power": 40,
          "element": "fire",
          "cooldown": 0,
          "accuracy": 95,
          "description": "技能描述",
          "effect": null
        },
        {
          "name": "技能名2",
          "type": "attack",
          "power": 65,
          "element": "fire",
          "cooldown": 2,
          "accuracy": 85,
          "description": "技能描述",
          "effect": {
            "type": "burn",
            "duration": 2,
            "damage_per_turn": 5
          }
        }
      ]
    }
    ```

    ## 属性分配指南

    - 如果描述强调速度/快，speed 偏高
    - 如果描述强调力量/攻击，attack 偏高
    - 如果描述强调防御/护甲/坚硬，defense 偏高
    - 如果描述强调耐力/血量厚，hp 偏高
    - 每项属性最少为 5

    请根据孩子的描述生成角色 JSON。
    """

    /// 构建用户消息
    static func userMessage(description: String) -> String {
        "请根据以下描述创建一个游戏角色：\(description)"
    }

    /// 构建完整的消息列表
    static func buildMessages(description: String) -> [ChatMessage] {
        [
            ChatMessage(role: "system", content: systemPrompt),
            ChatMessage(role: "user", content: userMessage(description: description))
        ]
    }
}
