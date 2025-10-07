# lib/stackoverflow_clone_web/components/search_components.ex
defmodule StackoverflowCloneWeb.SearchComponents do
  use Phoenix.Component
  import StackoverflowCloneWeb.CoreComponents

  attr :query, :string, required: true
  attr :loading, :boolean, default: false

  def search_form(assigns) do
    ~H"""
    <form phx-submit="search" class="w-full">
      <div class="relative">
        <input
          type="text"
          name="query"
          value={@query}
          phx-change="update_query"
          placeholder="Search for questions..."
          class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
          disabled={@loading}
        />
        <button
          type="submit"
          disabled={@loading}
          class="absolute right-2 top-1/2 transform -translate-y-1/2 bg-orange-500 text-white px-4 py-2 rounded-md hover:bg-orange-600 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          <%= if @loading do %>
            <.icon name="hero-arrow-path" class="h-5 w-5 animate-spin" />
          <% else %>
            Search
          <% end %>
        </button>
      </div>
    </form>
    """
  end

  attr :recent_searches, :list, required: true

  def recent_searches_sidebar(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
      <h3 class="text-sm font-semibold text-gray-900 mb-3">Recent Searches</h3>
      <%= if @recent_searches == [] do %>
        <p class="text-sm text-gray-500">No recent searches</p>
      <% else %>
        <ul class="space-y-2">
          <%= for search <- @recent_searches do %>
            <li>
              <button
                phx-click="select_recent_search"
                phx-value-search-id={search.id}
                class="w-full text-left text-sm text-gray-700 hover:text-orange-500 hover:bg-orange-50 p-2 rounded transition-colors truncate"
              >
                <%= search.query_text %>
              </button>
            </li>
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end

  attr :question, :map, required: true
  attr :answers, :list, required: true
  attr :llm_ranked_answers, :list, required: true
  attr :active_tab, :string, required: true
  attr :llm_loading, :boolean, default: false

  def question_display(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Question Card -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="p-6">
          <div class="flex items-start space-x-4">
            <div class="flex flex-col items-center space-y-2">
              <button class="text-gray-400 hover:text-orange-500">
                <.icon name="hero-chevron-up" class="h-8 w-8" />
              </button>
              <span class="text-2xl font-semibold text-gray-700"><%= @question.score %></span>
              <button class="text-gray-400 hover:text-orange-500">
                <.icon name="hero-chevron-down" class="h-8 w-8" />
              </button>
            </div>

            <div class="flex-1">
              <h2 class="text-2xl font-semibold text-gray-900 mb-4"><%= @question.title %></h2>

              <%= if @question.body do %>
                <div class="prose max-w-none mb-4">
                  <%= Phoenix.HTML.raw(sanitize_html(@question.body)) %>
                </div>
              <% end %>

              <div class="flex items-center space-x-4 text-sm text-gray-500">
                <%= if @question.tags && length(@question.tags) > 0 do %>
                  <div class="flex flex-wrap gap-2">
                    <%= for tag <- @question.tags do %>
                      <span class="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs">
                        <%= tag %>
                      </span>
                    <% end %>
                  </div>
                <% end %>

                <span><%= @question.view_count %> views</span>
                <span><%= @question.answer_count %> answers</span>
              </div>

              <div class="mt-4 flex items-center justify-between">
                <div class="text-sm text-gray-600">
                  Asked by <span class="font-medium"><%= @question.owner_display_name || "Anonymous" %></span>
                  <%= if @question.owner_reputation do %>
                    <span class="text-gray-500">(reputation: <%= @question.owner_reputation %>)</span>
                  <% end %>
                </div>

                <a
                  href={@question.link}
                  target="_blank"
                  class="text-orange-500 hover:text-orange-600 text-sm font-medium"
                >
                  View on Stack Overflow →
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Answers Section -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="border-b border-gray-200">
          <.answer_tabs
            active_tab={@active_tab}
            has_llm_rankings={length(@llm_ranked_answers) > 0}
            llm_loading={@llm_loading}
            answer_count={length(@answers)}
          />
        </div>

        <div class="p-6">
          <%= if @active_tab == "original" do %>
            <.answers_list answers={@answers} />
          <% else %>
            <%= if @llm_loading do %>
              <div class="flex items-center justify-center py-12">
                <.icon name="hero-arrow-path" class="h-8 w-8 animate-spin text-orange-500" />
                <span class="ml-3 text-gray-600">LLM is ranking answers...</span>
              </div>
            <% else %>
              <%= if length(@llm_ranked_answers) > 0 do %>
                <.llm_ranked_answers_list llm_ranked_answers={@llm_ranked_answers} />
              <% else %>
                <div class="text-center py-12">
                  <p class="text-gray-600 mb-4">LLM ranking not available yet</p>
                  <button
                    phx-click="trigger_llm_ranking"
                    class="bg-orange-500 text-white px-6 py-2 rounded-md hover:bg-orange-600"
                  >
                    Rank with LLM
                  </button>
                </div>
              <% end %>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :active_tab, :string, required: true
  attr :has_llm_rankings, :boolean, required: true
  attr :llm_loading, :boolean, required: true
  attr :answer_count, :integer, required: true

  def answer_tabs(assigns) do
    ~H"""
    <nav class="flex space-x-8 px-6" aria-label="Tabs">
      <button
        phx-click="switch_tab"
        phx-value-tab="original"
        class={[
          "py-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap",
          if(@active_tab == "original",
            do: "border-orange-500 text-orange-600",
            else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
          )
        ]}
      >
        Original Ranking (<%= @answer_count %>)
      </button>

      <button
        phx-click="switch_tab"
        phx-value-tab="llm_ranked"
        class={[
          "py-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap flex items-center",
          if(@active_tab == "llm_ranked",
            do: "border-orange-500 text-orange-600",
            else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
          )
        ]}
      >
        LLM Ranked
        <%= if @llm_loading do %>
          <.icon name="hero-arrow-path" class="ml-2 h-4 w-4 animate-spin" />
        <% end %>
        <%= if @has_llm_rankings do %>
          <span class="ml-2 bg-green-100 text-green-800 text-xs px-2 py-0.5 rounded-full">
            ✓
          </span>
        <% end %>
      </button>
    </nav>
    """
  end

  attr :answers, :list, required: true

  def answers_list(assigns) do
    ~H"""
    <div class="space-y-6">
      <h3 class="text-lg font-semibold text-gray-900">
        <%= length(@answers) %> <%= if length(@answers) == 1, do: "Answer", else: "Answers" %>
      </h3>

      <%= for answer <- @answers do %>
        <.answer_card answer={answer} />
      <% end %>
    </div>
    """
  end

  attr :answer, :map, required: true

  def answer_card(assigns) do
    ~H"""
    <div class="border-t border-gray-200 pt-6">
      <div class="flex items-start space-x-4">
        <div class="flex flex-col items-center space-y-2">
          <button class="text-gray-400 hover:text-orange-500">
            <.icon name="hero-chevron-up" class="h-6 w-6" />
          </button>
          <span class="text-xl font-semibold text-gray-700"><%= @answer.score %></span>
          <button class="text-gray-400 hover:text-orange-500">
            <.icon name="hero-chevron-down" class="h-6 w-6" />
          </button>
          <%= if @answer.is_accepted do %>
            <.icon name="hero-check-circle" class="h-6 w-6 text-green-500" />
          <% end %>
        </div>

        <div class="flex-1">
          <div class="prose max-w-none">
          <%= Phoenix.HTML.raw(sanitize_html(@answer.body)) %>
          </div>

          <div class="mt-4 text-sm text-gray-600">
            Answered by <span class="font-medium"><%= @answer.owner_display_name || "Anonymous" %></span>
            <%= if @answer.owner_reputation do %>
              <span class="text-gray-500">(reputation: <%= @answer.owner_reputation %>)</span>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :llm_ranked_answers, :list, required: true

  def llm_ranked_answers_list(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold text-gray-900">
          LLM Ranked Answers
        </h3>
        <span class="text-sm text-gray-500">
          Ranked by <%= Enum.at(@llm_ranked_answers, 0).llm_model_used %>
        </span>
      </div>

      <%= for ranked <- @llm_ranked_answers do %>
        <.llm_ranked_answer_card ranked={ranked} />
      <% end %>
    </div>
    """
  end

  attr :ranked, :map, required: true

  def llm_ranked_answer_card(assigns) do
    ~H"""
    <div class="border-t border-gray-200 pt-6">
      <div class="flex items-start space-x-4">
        <div class="flex flex-col items-center space-y-2">
          <div class="bg-orange-500 text-white rounded-full w-10 h-10 flex items-center justify-center font-bold">
            #<%= @ranked.llm_rank %>
          </div>
          <%= if @ranked.llm_confidence_score do %>
            <span class="text-xs text-gray-500">
              <%= Float.round(@ranked.llm_confidence_score * 100, 0) %>%
            </span>
          <% end %>
        </div>

        <div class="flex-1">
          <%= if @ranked.llm_reasoning do %>
            <div class="mb-3 p-3 bg-blue-50 border-l-4 border-blue-400 rounded">
              <p class="text-sm text-blue-900">
                <span class="font-semibold">LLM Analysis:</span> <%= @ranked.llm_reasoning %>
              </p>
            </div>
          <% end %>

          <div class="flex items-start space-x-4">
            <div class="flex flex-col items-center space-y-2">
              <span class="text-xl font-semibold text-gray-700"><%= @ranked.answer.score %></span>
              <%= if @ranked.answer.is_accepted do %>
                <.icon name="hero-check-circle" class="h-5 w-5 text-green-500" />
              <% end %>
            </div>

            <div class="flex-1">
              <div class="prose max-w-none">
                <%= Phoenix.HTML.raw(sanitize_html(@ranked.answer.body)) %>
              </div>

              <div class="mt-4 text-sm text-gray-600">
                Answered by <span class="font-medium"><%= @ranked.answer.owner_display_name || "Anonymous" %></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def loading_state(assigns) do
    ~H"""
    <div class="flex items-center justify-center py-24">
      <div class="text-center">
        <.icon name="hero-arrow-path" class="h-12 w-12 animate-spin text-orange-500 mx-auto" />
        <p class="mt-4 text-lg text-gray-600">Searching Stack Overflow...</p>
      </div>
    </div>
    """
  end

  attr :error, :string, required: true

  def error_state(assigns) do
    ~H"""
    <div class="bg-red-50 border border-red-200 rounded-lg p-6">
      <div class="flex">
        <.icon name="hero-exclamation-circle" class="h-6 w-6 text-red-600" />
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error</h3>
          <p class="mt-2 text-sm text-red-700"><%= @error %></p>
        </div>
      </div>
    </div>
    """
  end

  def empty_state(assigns) do
    ~H"""
    <div class="text-center py-24">
      <.icon name="hero-magnifying-glass" class="h-16 w-16 text-gray-400 mx-auto" />
      <h3 class="mt-4 text-lg font-medium text-gray-900">Search Stack Overflow</h3>
      <p class="mt-2 text-sm text-gray-500">
        Enter a question above to search for answers
      </p>
    </div>
    """
  end

  defp sanitize_html(html) do
    HtmlSanitizeEx.basic_html(html)
  end
end
