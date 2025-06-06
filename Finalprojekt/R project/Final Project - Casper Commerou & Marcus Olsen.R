# 
library(tokenizers)
library(tidyverse)
library(tidytext)
library(here)
library(pdftools)
library(Sentida)
library(stringr)
library(purrr)
library(ggplot2)

#til brug senere
get_context <- function(words, index, window = 7) {
  start <- max(1, index - window)
  end <- min(length(words), index + window)
  paste(words[start:end], collapse = " ")
}

#keywords
rural_keywords <- c(
  "landet", "landlig", "landskab", "bondegård", "gård", "landsby", "landsogn", "sogn",
  "præstegård", "mark", "eng", "hede", "skov", "skovkant", "ager", "jord", "landarbejde",
  "høst", "hømark", "høstak", "pløjemark", "hegn", "grøft", "stald", "mødding",
  "høns", "kvæg", "kreatur", "bonde", "husmand", "landbo", "tjenestekarl", "hyrde",
  "markarbejder", "sognevej", "grusvej", "landevej", "landluft", "natur", "bakke", "dal",
  "flod", "bæk", "foder", "hø", "roer", "landidyl", "øde",
  "naturen", "jordnær", "hjemstavn", "fødegård", "egn",
  "hjemegn", "provinserne", "udkant", "fjerntliggende"
)
urban_keywords <- c(
  "by", "storby", "hovedstad", "købstad", "kvarter", "centrum", "gade", "stræde", "torv",
  "plads", "bygade", "baggård", "forstad", "boligkarré", "lejlighed", "fabrik", "værksted",
  "kontor", "sporvogn", "diligence", "hestevogn", "banegård", "jernbane", "gadelampe",
  "brosten", "brolægning", "fortov", "kloak", "skorstene", "fabriksrøg", "gaslampe",
  "mængde", "menneskemylder", "borger", "embedsmand", "købmand", "butik",
  "kunde", "tyv", "tigger", "prostitueret", "tjenestefolk", "pulserende",
  "moderne", "civiliseret", "oplyst", "mangfoldig",
  "nytidig", "overfyldt", "forurenet",
  "fremmedgjort"
)


# sentiment
analyser_sentiment_kontekst <- function(pdf_path, rural_keywords, urban_keywords, window = 7) {
  text <- pdf_text(pdf_path)
  full_text <- paste(text, collapse = " ")
  words <- tokenize_words(full_text, lowercase = TRUE)[[1]]
  
  get_context <- function(words, index, window) {
    start <- max(1, index - window)
    end <- min(length(words), index + window)
    paste(words[start:end], collapse = " ")
  }
  
  safe_sentida <- function(text) {
    tryCatch(
      sentida(text, output = "total"),
      error = function(e) NA_real_
    )
  }
  
  rural_positions <- which(words %in% rural_keywords)
  urban_positions <- which(words %in% urban_keywords)
  
  rural_sentiments <- map_dbl(rural_positions, ~ safe_sentida(get_context(words, .x, window)))
  urban_sentiments <- map_dbl(urban_positions, ~ safe_sentida(get_context(words, .x, window)))
  
  df_sentiments <- tibble(
    theme = c(rep("rural", length(rural_sentiments)), rep("urban", length(urban_sentiments))),
    sentiment = c(rural_sentiments, urban_sentiments)
  ) %>% filter(!is.na(sentiment))
  
  return(df_sentiments)
}

### Spillemand sentiment


df_spillemand <- analyser_sentiment_kontekst(here("data/Kun en Spillemand.pdf"), rural_keywords, urban_keywords)

df_spillemand %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_spillemand, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in Spillemand", x = "Sentiment", y = "Densitet")

### Digtsamling sentiment


df_digte <- analyser_sentiment_kontekst(here("data/digtsamling (1).pdf"), rural_keywords, urban_keywords)

df_digte %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_digte, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in collection of poems", x = "Sentiment", y = "Densitet")

### Fra Hytterne sentiment


df_hytterne <- analyser_sentiment_kontekst(here("data/Fra Hytterne.pdf"), rural_keywords, urban_keywords)

df_hytterne %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_hytterne, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in Fra Hytterne", x = "Sentiment", y = "Densitet")


### Det Forjættede Land sentiment


df_land <- analyser_sentiment_kontekst(here("data/Det-forjaettede-land.pdf"), rural_keywords, urban_keywords)

df_land %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_land, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in Det Forjættede Land", x = "Sentiment", y = "Densitet")


### Stuk sentiment

df_stuk <- analyser_sentiment_kontekst(here("data/stuk_pdf.pdf"), rural_keywords, urban_keywords)


df_stuk %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_stuk, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in Stuk", x = "Sentiment", y = "Densitet")

### Guldhornene sentiment

df_guld <- analyser_sentiment_kontekst(here("data/Kildepapir.pdf"), rural_keywords, urban_keywords)


df_guld %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_guld, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in Guldhornene", x = "Sentiment", y = "Densitet")

### Et dukkehjem sentiment

df_nora <- analyser_sentiment_kontekst(here("data/Nora - et dukkehjem, skuespildrama, Henrik Ibsen.pdf"), rural_keywords, urban_keywords)


df_nora %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_nora, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in Et dukkehjem", x = "Sentiment", y = "Densitet")

### Lykke-per sentiment

df_per <- analyser_sentiment_kontekst(here("data/Lykke-Per komplet.pdf"), rural_keywords, urban_keywords)


df_per %>%
  group_by(theme) %>%
  summarise(mean = mean(sentiment), median = median(sentiment), n = n())

ggplot(df_per, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  labs(title = "Sentiment for rural vs urban in Lykke-Per", x = "Sentiment", y = "Densitet")


# Titel til tekst
df_spillemand <- df_spillemand %>% mutate(tekst = "Kun en Spillemand")
df_stuk      <- df_stuk %>% mutate(tekst = "Stuk")
df_guld      <- df_guld %>% mutate(tekst = "Guldhornene")
df_nora      <- df_nora %>% mutate(tekst = "Et Dukkehjem")
df_per       <- df_per %>% mutate(tekst = "Lykke-Per")
df_hytterne <- df_hytterne %>% mutate(tekst = "Fra Hytterne")
df_land <- df_land %>% mutate(tekst = "Det Forjættede Land")
df_digte <- df_digte %>% mutate(tekst = "Digtsamling")

# Samlede grafer
df_alle <- bind_rows(df_spillemand, df_stuk, df_guld, df_nora, df_per, df_land, df_hytterne, df_digte)

ggplot(df_alle, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ tekst, scales = "free") +
  labs(title = "Sentiment density for rural vs urban comparison",
       x = "Sentiment", y = "Density", fill = "Theme") +
  theme_minimal()

ggplot(df_alle, aes(x = tekst, y = sentiment, fill = theme)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  labs(title = "Sentiment comparison",
       x = "Text", y = "Sentiment", fill = "Theme") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

df_alle %>%
  group_by(tekst, theme) %>%
  summarise(
    mean_sentiment = mean(sentiment, na.rm = TRUE),
    median_sentiment = median(sentiment, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )
df_stats <- df_alle %>%
  group_by(tekst, theme) %>%
  summarise(
    mean_sentiment = mean(sentiment, na.rm = TRUE),
    median_sentiment = median(sentiment, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )
ggplot(df_stats, aes(x = tekst, y = mean_sentiment, fill = theme)) +
  geom_col(position = position_dodge(width = 0.8)) +
  labs(title = "Average sentiment for rural vs urban themes",
       x = "Text", y = "Gennemsnitligt sentiment", fill = "Themes") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




sentiment_udvikling_over_tid <- function(pdf_paths, rural_keywords, urban_keywords, window = 5, segments = 100) {
  
  if (length(pdf_paths) == 1) {
    full_text <- pdf_text(pdf_paths)
  } else {
    all_texts <- map(pdf_paths, pdf_text)
    full_text <- unlist(all_texts)
  }
  full_text <- paste(full_text, collapse = " ")
  
  # Tokenize
  words <- tokenize_words(full_text, lowercase = TRUE)[[1]]
  n_words <- length(words)
  
  # kontekts
  get_context <- function(words, index, window) {
    start <- max(1, index - window)
    end <- min(length(words), index + window)
    context_words <- words[start:end]
    paste(context_words, collapse = " ")
  }
  
  safe_sentida <- function(text) {
    tryCatch(sentida(text, output = "total"), error = function(e) NA_real_)
  }
  
  # Segment
  segment_indices <- cut(seq_along(words), breaks = segments, labels = FALSE)
  
  # Segment tema
  results <- tibble(
    word = words,
    index = seq_along(words),
    segment = segment_indices
  ) %>%
    filter(word %in% c(rural_keywords, urban_keywords)) %>%
    mutate(
      theme = case_when(
        word %in% rural_keywords ~ "rural",
        word %in% urban_keywords ~ "urban"
      ),
      context = map_chr(index, ~get_context(words, .x, window)),
      sentiment = map_dbl(context, safe_sentida)
    ) %>%
    filter(!is.na(sentiment)) %>%
    group_by(segment, theme) %>%
    summarise(mean_sentiment = mean(sentiment), .groups = "drop")
  
  return(results)
}

# Spillemand segment
df_spillemand_tid <- sentiment_udvikling_over_tid(
  pdf_paths = c(here("data/Kun en Spillemand.pdf")),
  rural_keywords,
  urban_keywords,
  segments = 10
)

ggplot(df_spillemand_tid, aes(x = segment, y = mean_sentiment, color = theme)) +
  geom_line(size = 1) +
  labs(title = "'Kun en Spillemand' progression",
       x = "Segment (start to finish)",
       y = "Average sentiment",
       color = "Theme") +
  theme_minimal()



# Lykke-Per segment
df_spillemand_tid <- sentiment_udvikling_over_tid(
  pdf_paths = c(here("data/Lykke-Per komplet.pdf")),
  rural_keywords,
  urban_keywords,
  segments = 
)

ggplot(df_spillemand_tid, aes(x = segment, y = mean_sentiment, color = theme)) +
  geom_line(size = 1) +
  labs(title = "'Det forjættede land' progression",
       x = "Segment (start to finish)",
       y = "Average sentiment",
       color = "Theme") +
  theme_minimal()




ggplot(df_alle, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ tekst, scales = "free_y") +
  labs(
    title = "Sentimentfordeling for rural vs urban temaer i hver tekst",
    x = "Sentiment",
    y = "Densitet",
    fill = "Tema"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("rural" = "#1b9e77", "urban" = "#d95f02"))


df_spillemand_rural_context <- df_spillemand %>%
  filter(theme == "rural") %>%
  mutate(context = map_chr(seq_along(sentiment), ~get_context(words, rural_positions[.x], 5))) %>%
  unnest_tokens(word, context) %>%
  anti_join(get_stopwords(language = "da")) %>%
  count(word, sort = TRUE)


df_spillemand_urban_context <- df_spillemand %>%
  filter(theme == "urban") %>%
  mutate(context = map_chr(seq_along(sentiment), ~get_context(words, urban_positions[.x], 5))) %>%
  unnest_tokens(word, context) %>%
  anti_join(get_stopwords(language = "da")) %>%
  count(word, sort = TRUE)

ggplot(df_alle, aes(x = sentiment, fill = theme)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ tekst, scales = "free_y") +
  labs(title = "Sentiment-fordeling (rural vs. urban) pr. tekst", x = "Sentiment-score", y = "Densitet") + theme_minimal()

# Define the modified function to include sentiment scores and a seed parameter
udtraek_eksempler_kontekst <- function(words, keyword_positions, sentiment_scores, n = 6, window = 3, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  sampled_indices <- sample(seq_along(keyword_positions), size = min(n, length(keyword_positions)))
  sampled_positions <- keyword_positions[sampled_indices]
  sampled_sentiments <- sentiment_scores[sampled_indices]
  
  tibble(
    keyword = words[sampled_positions],
    context = map_chr(sampled_indices, function(idx) {
      pos <- keyword_positions[idx]
      start <- max(1, pos - window)
      end <- min(length(words), pos + window)
      paste(words[start:end], collapse = " ")
    }),
    sentiment = sampled_sentiments
  )
}

text_hytterne <- pdf_text(here("data/Fra Hytterne.pdf"))
full_text_hytterne <- paste(text_hytterne, collapse = " ")
words <- tokenize_words(full_text_hytterne, lowercase = TRUE)[[1]]

rural_positions <- which(words %in% rural_keywords)
urban_positions <- which(words %in% urban_keywords)


df_hytterne <- analyser_sentiment_kontekst(here("data/Fra Hytterne.pdf"), rural_keywords, urban_keywords)
rural_sentiments <- df_hytterne %>% filter(theme == "rural") %>% pull(sentiment)
urban_sentiments <- df_hytterne %>% filter(theme == "urban") %>% pull(sentiment)


rural_eksempler <- udtraek_eksempler_kontekst(words, rural_positions, rural_sentiments, seed = 123)
urban_eksempler <- udtraek_eksempler_kontekst(words, urban_positions, urban_sentiments, seed = 123)

print(rural_eksempler)

print(urban_eksempler)
