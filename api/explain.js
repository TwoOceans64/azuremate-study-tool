module.exports = async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({ error: "POST only" });
  const question = String((req.body && req.body.question) || "").trim().slice(0, 500);
  if (!question) return res.status(400).json({ error: "Missing question" });
  try {
    const r = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": process.env.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-haiku-5-5",
        max_tokens: 400,
        system: "You are a friendly tutor for the Microsoft AZ-900 (Azure Fundamentals) exam. Explain in plain English for a complete beginner, in under 130 words. Give one everyday analogy, then finish with a line starting 'Exam tip:'. Stay on Azure and cloud topics; if the question is unrelated, say so briefly.",
        messages: [{ role: "user", content: question }],
      }),
    });
    if (!r.ok) return res.status(502).json({ error: "The AI service is unavailable right now." });
    const j = await r.json();
    res.status(200).json({ text: (j.content || []).map((b) => b.text || "").join("") });
  } catch (e) {
    res.status(500).json({ error: "Something went wrong. Try again." });
  }
};
